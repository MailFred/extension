class MailButler

  constructor: (@prefix) ->

  @LABEL_BASE: "MailButler"
  @LABEL_OUTBOX: MailButler.LABEL_BASE + "/" + "Outbox"
  @KEY_PREFIX_MESSAGE: "msg_"
  @FREQUENCY_MINUTES: 1

  prefix: null

  scheduleJson: (params) ->
    try
      @addButlerMail params
      @result null, true
    catch e
      @result e

  scheduleSetup: (params) ->
    try
      @addButlerMail params
      true
    catch e
      e

  result: (err, result) ->
    ret = []
    if @prefix
      ret.push @prefix
      ret.push '('

    ret.push Utilities.jsonStringify if err then error: err else success: result

    if @prefix
      ret.push ')'

    ContentService.createTextOutput(ret.join '').setMimeType ContentService.MimeType.JSON

  @setup: ->
    if ScriptApp.getScriptTriggers().length is 0
      Logger.log "Installing trigger"
      ScriptApp.newTrigger("process").timeBased().everyMinutes(MailButler.FREQUENCY_MINUTES).create()
    return

  @processButlerMails: (d) ->
    Logger.log "Checking for scheduled mails on %s", d

    validKeys = []
    for key in UserProperties.getKeys()
      if @isButlerMessage key
        validKeys.push key

    if validKeys.length > 0
      
      # yep there are some
      Logger.log "Found %s possible candidates", validKeys.length

      now = d.getTime()
      for key in validKeys
        props = @getButlerMail key, true
        @processButlerMail props  if isNaN(props.when) or props.when <= now

    else
      # No scheduled messages available
      Logger.log "...none found."
    return

  @processButlerMail: (props) ->
    Logger.log "Process mail with props: %s", props

    messageId = props.messageId
    message = GmailApp.getMessageById messageId if messageId

    unless message
      # Message does not exist or is invalid
      Logger.log "Message with ID '%s' does not exist or is invalid", messageId

    else
      # Message does exist
      
      # refresh its state
      message.refresh()

      # get the thread the email belongs to
      # message.getThread() seems to return the wrong number of messages (only one message)
      thread = GmailApp.getThreadById message.getThread().getId()

      # refresh the thread
      thread.refresh()

      if @hasLabel @LABEL_OUTBOX, thread
        # Has the outbox label
        Logger.log "Start processing message with ID '%s'", messageId
        
        # remove the outbox label from the message
        @removeLabel @LABEL_OUTBOX, thread

        # By default we assume there was no answer - this is also correct if the user doesn't care about answers
        hasAnswer = false

        if props.how.noanswer
          # all the actions shall only take place if there was no answer

          # find the date of the last message
          dateOfLastMessage = thread.getLastMessageDate()
          Logger.log "Action was scheduled on '%s' and date of last message was %s ", new Date(props.scheduled).toUTCString(), dateOfLastMessage.toUTCString()
          
          # check if that message was sent after or on the scheduling date
          hasAnswer = dateOfLastMessage.getTime() >= props.scheduled

        unless hasAnswer 
          # do all the processing only if there was no answer
          # (or the 'noanswer' setting was not set at all, 
          # e.g. the user doesn't care whether there was activity or not)
          
          # star it only if not starred yet and if starring is enabled
          message.star()  if props.how.star and not message.isStarred()
          
          # mark it unread only if not unread and marking unread is enabled
          thread.markUnread()  if props.how.unread and not thread.isUnread()
          
          # move it to inbox only if not in inbox already and moving is enabled
          GmailApp.moveThreadToInbox thread ? message.getThread()  if props.how.inbox and not thread.isInInbox()

        else
          # There was an answer on this thread
          Logger.log "The message has been answered to already..."

      else
        # does not have the outbox label
        Logger.log "Label '%s' has been removed from the mail, not processing it", @LABEL_OUTBOX
    
      Logger.log "Finished processing message with ID '%s'", messageId

    # delete the scheduled butler mail, because we couldn't find the real message
    @deleteButlerMail messageId # pass "" + x in case messageId is undefined (should not happen)
    return

  # Get a label or create it
  @getLabel: (name, create) ->
    GmailApp.getUserLabelByName(name) ? (GmailApp.createLabel(name) if create)

  # Add a label to a message (thread) - create newly if needed
  @addLabel: (name, thread) ->
    @getLabel(name, true)?.addToThread thread
    return

  # Checks if a given message (thread) has a specified label attached
  @hasLabel: (name, thread) ->
    for label in thread.getLabels()
      return true if label.getName() is name
    false

  # Removes a label from a message (thread)
  @removeLabel: (name, thread) ->
    @getLabel(name, false)?.removeFromThread thread
    return

  @normalize: (messageId, noPrefix) ->
    ((if noPrefix then "" else @KEY_PREFIX_MESSAGE)) + ("" + messageId).toLowerCase()

  @isButlerMessage: (key) ->
    key?.indexOf(@KEY_PREFIX_MESSAGE) is 0

  @storeButlerMail: (props) ->
    UserProperties.setProperty @normalize(props.messageId), Utilities.jsonStringify props
    return

  @getButlerMail: (messageId, noPrefix) ->
    Utilities.jsonParse UserProperties.getProperty (@normalize messageId, noPrefix)

  @deleteButlerMail: (messageId) ->
    Logger.log "Removing scheduled message with ID '%s'", messageId
    UserProperties.deleteProperty @normalize messageId
    return

  addButlerMail: (form) ->
    messageId = form.msgId ? form.messageId

    if not messageId or not (message = GmailApp.getMessageById messageId)
      Logger.log "Given message ID '%s' is not valid", messageId
      throw "Given message ID '#{messageId}' is not valid"

    now = new Date().getTime()
    matches = form.when?.match /^(delta|specified):([0-9]+)/
    w = switch matches?[1]
      when 'delta' then now + Number matches[2]
      when 'specified' then Number matches[2]
      else
        unless form.when
          Logger.log 'No scheduling time given'
          throw 'No scheduling time given'
        else
          Logger.log "Given scheduling time '%s' is not valid", form.when
          throw "Given scheduling time '#{form.when}' is not valid"

    props =
      messageId: messageId
      when: w
      scheduled: now
      how:
        star:     String(form.star)     is "true"
        unread:   String(form.unread)   is "true"
        inbox:    String(form.inbox)    is "true"
        noanswer: String(form.noanswer) is "true"

    unless props.how.star or props.how.unread or props.how.inbox
      Logger.log "No action specified"
      throw "No action (star, marking unread, move to inbox) specified"

    MailButler.storeButlerMail props

    thread = GmailApp.getThreadById message.getThread().getId()
    thread.moveToArchive() if String(form.archive) is "true"

    MailButler.addLabel MailButler.LABEL_BASE, thread
    MailButler.addLabel MailButler.LABEL_OUTBOX, thread

    return

doGet = (request) ->
  MailButler.setup()
  
  butler = new MailButler request.parameter.callback

  switch request.parameter.action
    when 'schedule'
      out = butler.scheduleJson request.parameter
    when 'setup'
      success = butler.scheduleSetup request.parameter
      out = ContentService.createTextOutput 'Setup complete!'
      if success is true
        out.append "\nYour email has been scheduled, you can close this window now!"
      else
        out.append "\nBut something went wrong: #{success}"
    else
      out = ContentService.createTextOutput 'Service status: OK'
  out

# This is just a helper until the Google Apps Script Code Editor can deal with bla = function assignments
`function process() {
  _process.apply(this, arguments);
}`

_process = (e) ->
  
  # Get a lock for the current user
  lock = LockService.getPrivateLock()
  if lock.tryLock(10000)
    
    # wait 10 seconds at most
    Logger.log "We have the lock...start"
    
    # Get the time this scheduled execution started
    d = new Date()
    if e
      d.setUTCDate e["day-of-month"]
      d.setUTCFullYear e.year
      d.setUTCMonth e.month
      d.setUTCHours e.hour
      d.setUTCMinutes e.minute
      d.setUTCSeconds e.second

    MailButler.processButlerMails d
  
  # release our lock
  lock.releaseLock()
  return

#`function onInstall() {
#  MailButler.setup();
#}`


`function revoke() {
  ScriptApp.invalidateAuth();
}`

_test = ->
  doGet
    parameter:
      msgId: "13a1a6948cb7471f" # works with joscha@feth.com only
      when: "delta:"+ (2 * 1000 * 60)
      inbox: true
      unread: true
      noanswer: true
      action: 'schedule'
  return

# This is just a helper until the Google Apps Script Code Editor can deal with bla = function assignments
`function test() {
  _test.apply(this, arguments);
}`

#deleteProps = ->
#  UserProperties.deleteAllProperties()
#  return

#testLastMessageDate = ->
#  message = GmailApp.getMessageById("13a1a6948cb7471f")
#  thread = GmailApp.getThreadById(message.getThread().getId())
#  Logger.log thread.getLastMessageDate().toUTCString()
#  Logger.log thread.getMessageCount()
#  msgs = thread.getMessages()
#  for msg in msgs
#    Logger.log msg.getDate().toUTCString()
#  return

#testProps = ->
#  Logger.log UserProperties.getProperties()
#  return

#getTriggers = ->
#  Logger.log "triggers: %s", ScriptApp.getScriptTriggers()
#  return
