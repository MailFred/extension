(($, window, ExtensionFacade, Q, Eventr) ->

  log = (args...) ->
    window.trackJs.console.log.apply window.trackJs.console, args
    return unless console?.log
    mb?.getDebug().then (debug) ->
      if debug
        args.unshift "[#{M.CLS}]"
        console.log.apply console, args
      return
    return

  track = (args) ->
    try
      trackJs.track JSON.stringify args
    catch err
      # ignore
    return

  __msg = (key, substitutions) ->
    deferred = Q.defer()
    ExtensionFacade.i18n key, substitutions, deferred.resolve
    deferred.promise

  currentGmailDeferred = Q.defer()

  SERVICE_URL = 'https://api.mailfred.de'

  class M

    @SCHEDULE_SUFFIX: '/schedule'
    @SETUP_URL_SUFFIX: '/setup'

    @CLS:         'mailfred'
    #@CLS_NAV:     M.CLS + '-nav'
    @CLS_THREAD:   M.CLS + '-thread'
    @CLS_POPUP:    M.CLS + '-popup'
    @CLS_MENU:     M.CLS + '-menu'
    @CLS_PICKER:   M.CLS + '-picker'
    @CLS_LOADER:   M.CLS + '-loader'
    @CLS_AUTH_IMG: M.CLS + '-auth-image'
    @CLS_AUTH_TXT: M.CLS + '-auth-text'
    @CLS_WLCM_DLG: M.CLS + '-welcome-dialog'

    @ID_PREFIX:    M.CLS + '-id-'

    @TYPE_THREAD:  'thread'
    @TYPE_NAV:     'nav'

    @STORE:
      BOX_SETTING:  'settings'
      DEBUG:        'debug'
      EMAIL:        'email'
      LAST_VERSION: 'lastVersion'

    @GM_SEL:
      ARCHIVE_BUTTON:                 '.T-I.J-J5-Ji.lR.T-I-ax7.T-I-Js-IF.ar7:visible'
      THREAD_BUTTON_BAR:              '.iH > div'
      INSERT_AFTER:                   '.G-Ni.J-J5-Ji:visible:nth-child(3)'
      PREVIEW_PANE_ENABLED:           '.apF .apJ'
      PREVIEW_PANE_THREAD_BUTTON_BAR:  "[gh='mtb'] > div > div"

    settingProps: {}
    selectedConversationId: null

    currentView: null

    constructor: ->
      # console.log 'content script:construct'
      window.addEventListener "message", @listenToGmailr, false

      @initTrackJs()
      @checkVersion()
      return

    ###* This returns the service URL
         @return {Promise} resolves to the service URL {String}

       use the following with
       --allow-running-insecure-content
       to allow non-HTTPS calls
      'http://localhost:8080'
    ###
    getServiceUrl: ->
      deferred = Q.defer()
      deferred.resolve SERVICE_URL
      deferred.promise

    initTrackJs: ->
      @getVersion().then (version) =>
        @getCurrentGmail().then (email) ->
          opts =
            userId: email
            version: version
          log 'initializing TrackJS with', opts
          window.trackJs.configure opts
          return
        return
      return

    getDebug: ->
      deferred = Q.defer()
      ExtensionFacade.storage.local.get M.STORE.DEBUG, (items) ->
        deferred.resolve items[M.STORE.DEBUG]
        return
      deferred.promise

    getSettingEmail: ->
      deferred = Q.defer()
      ExtensionFacade.storage.local.get M.STORE.EMAIL, (items) ->
        deferred.resolve items[M.STORE.EMAIL]
        return
      deferred.promise


    getSettingProps: ->
      deferred = Q.defer()
      ExtensionFacade.storage.sync.get M.STORE.BOX_SETTING, (items) =>
        deferred.resolve items[M.STORE.BOX_SETTING]
        return

      deferred.promise

    @storeLastVersion: (version) ->
      store = {}
      store[M.STORE.LAST_VERSION] = version
      ExtensionFacade.storage.sync.set store, ->
        log 'Set the last used version to', version
        return
      return

    @getLastVersion: (resp) ->
      ExtensionFacade.storage.sync.get M.STORE.LAST_VERSION, (items) ->
        resp items[M.STORE.LAST_VERSION]
        return
      return

    @isAuthorisationErrorPage: (contents) -> /reauth/i.test contents

    @isAuthorisationErrorResponse: (resp) ->
      (resp?.toLowerCase().indexOf "authorization") isnt -1

    isAuthorised: ->
      log 'checking if the user authorised'
      deferred = new $.Deferred
      @getServiceUrl().then (url) ->
        url += M.SETUP_URL_SUFFIX

        error = ->
          log '...user is not authorised (yet/any more)'
          deferred.reject()
          return

        $.ajax
          url:      url
          dataType: 'json'
          cache:    false
          data:     format: 'json'
          success:  (data, textStatus, jqXHR) ->
            if data.success
              log '...user is still authorised'
              deferred.resolve()
            else
              error textStatus, jqXHR.responseText
            return
          error:    (jqXHR, textStatus, errorThrown) ->
            error textStatus, jqXHR.responseText
            return
      deferred.promise

    firstInstall: (version) ->
      log 'first install', version
      @welcome()
      return

    upgradeInstall: (oldVersion, newVersion) ->
      log 'upgrade from', oldVersion, newVersion
      @isAuthorised().fail =>
        @gettingStarted()
        return
      return

    sameInstall: (version) ->
      log 'no version change', version
      return

    inConversation: ->
      @currentView is 'conversation'

    activateArchiveButton: ->
      return unless @inConversation()
      button = ($ M.GM_SEL.ARCHIVE_BUTTON).get 0
      if button
        Eventr.simulate button, 'mousedown'
        Eventr.simulate button, 'mouseup'
      return

    ###* returns the email address of the currently
         logged in user
         @returns {Promise} a promise that resolves to the email address {String}
    ###
    getCurrentGmail: -> currentGmailDeferred.promise

    listenToGmailr: (e) =>
      if e.source is window
        # We only accept messages from ourselves
        # log "event from Gmailr", e

        if e.data?.from is "GMAILR"
          # log 'Got Gmailr event: ', e.data.event.type
          evt = e.data.event
          switch evt.type
            when 'init'
            # GMailr is ready
              currentGmailDeferred.resolve (evt.email ? '').trim() ? null
              # (__msg 'extName').then (name) -> GMailUI.Breadcrumbs.add name, => @gettingStarted()

              # kick GMailr into debug mode?
              @getDebug().then (debug) ->
                if debug
                  message =
                    from: 'MAILFRED'
                    type: 'debug.enable'
                  window.postMessage message, "*"
                return

            when 'viewThread'
            # User moves to previous or next convo
              @selectedConversationId = evt.args[0]
              @inject()
            when 'viewChanged'
            # User switches view (conversation <-> threads)
              @currentView = evt.args[0]
              log "User switched to #{@currentView} view"
              @inject()

      return

    ### returns the version of the extension
        @returns {Promise} resolves to the semver version {String}
    ###
    getVersion: ->
      log 'getting version'
      deferred = Q.defer()
      deferred.resolve ExtensionFacade.getVersion()
      deferred.promise

    checkVersion: ->
      # Get the extension version
      @getVersion().then (version) =>
        M.getLastVersion (lastVersion) =>
          unless lastVersion
            M.storeLastVersion version
            @firstInstall version
          else if lastVersion < version
            M.storeLastVersion version
            @upgradeInstall lastVersion, version
          else
            @sameInstall version
          return
        return
      return

    inject: ->
      return unless @inConversation()
      @getSettingEmail().then (settingEmail) =>
        log 'Email address in settings', settingEmail
        @getCurrentGmail().then (currentGmail) =>
          log 'Current Gmail window', currentGmail
          @injectThread() if (not settingEmail or not currentGmail) or currentGmail in settingEmail.split /[, ]+/ig
      return

    isPreviewPaneEnabled: ->
      ($ M.GM_SEL.PREVIEW_PANE_ENABLED).length > 0

    injectThread: ->
      log 'Injecting buttons in thread view'

      if @isPreviewPaneEnabled()
        # Preview pane is enabled
        sel = M.GM_SEL.PREVIEW_PANE_THREAD_BUTTON_BAR
      else
        # Preview pane is not enabled
        sel = M.GM_SEL.THREAD_BUTTON_BAR

      threads = ($ sel).filter (index) ->
        ($ ".#{M.CLS_THREAD}", @).length is 0

      if threads.length > 0
        after = threads.find M.GM_SEL.INSERT_AFTER
        @composeButton()
          .then (bar) ->
            bar.addClass 'T-I'
            if after.length > 0 then after.after bar else threads.append bar
            return
          .catch (err) ->
            track error: err
            return
      return

    actionOps: [
          'unread'
          'star'
          'inbox'
          ]

    getTexts: (key, time) ->
      ucFirst = (str) -> str[0].toUpperCase() + str.substring(1).toLowerCase()
      i18nKey = ucFirst key
      x = "menuTimePresetCloseFutureItem#{i18nKey}#{time}"
      Q.all [
        (__msg "#{x}Selected")
        (__msg x)
      ]

    getPresets: =>
      @getDebug().then (debug) ->
        presets = {}
        presets.minutes    = [5] if debug
        presets.hours      = [4]
        presets.hours.unshift 2 if debug
        presets.tomorrow   = [8,14]
        presets.days       = [2,7,14]
        presets.months     = [1] if debug
        presets

    composeButton: =>

      props =
        noanswer: false
        unread:   true
        star:     false
        inbox:    true
        archive:  true

      _.each props, (v, op) =>
        hasSetting = @settingProps and typeof @settingProps[op] isnt 'undefined'
        props[op] = !! @settingProps?[op] if hasSetting
        return

      presetMenu = null
      constraintSection = null
      timeSection = null
      errorSection = null
      pickerMenu = null
      button = null

      schedule = (wen) =>
        pickerMenu.close()
        presetMenu.close()
        button.close()
        button.addClass M.CLS_LOADER
        props.when = wen
        (@onSchedule props).finally ->
          button.removeClass M.CLS_LOADER
          return
        return

      isValid = =>
        valid = false
        for op in @actionOps
          valid |= props[op]
        valid = !!valid
        timeSection.toggle valid
        constraintSection.toggle valid
        errorSection.toggle !valid
        return

      propStoreFn = (checkbox, propName) =>
        checkbox.addOnChange (e, checked) =>
          props[propName] = checked
          toStore = {}
          toStore[M.STORE.BOX_SETTING] = props
          @settingProps = props
          ExtensionFacade.storage.sync.set toStore, ->
            log 'Storing properties finished'
            return
          isValid()
        return

      # UI

      bar = new GMailUI.ButtonBar()
      bar.addClass M.CLS
      bar.addClass M.CLS_THREAD

      popup = new GMailUI.Popup()
      popup.addClass M.CLS_POPUP

      __msg('menuMailActions')
        .then (label) ->
          log 'compose: actions'
          popup.append new GMailUI.PopupLabel label
          return
        .then ->
          # Actions section
          Q.all([
            (__msg 'mailActionMarkUnread')
            (__msg 'mailActionMarkUnreadTitle')
            (__msg 'mailActionStar')
            (__msg 'mailActionStarTitle')
            (__msg 'mailActionMoveToInbox')
            (__msg 'mailActionMoveToInboxTitle')
          ]).then ([markUnread, markUnreadTitle, star, starTitle, moveToInbox, moveToInboxTitle]) ->
            log 'compose: action section'
            actionSection = popup.append new GMailUI.Section
            actionSectionCheckboxes =
              unread: actionSection.append (new GMailUI.PopupCheckbox markUnread, props.unread, '', markUnreadTitle)
              star: actionSection.append (new GMailUI.PopupCheckbox star, props.star, '', starTitle)
              inbox: actionSection.append (new GMailUI.PopupCheckbox moveToInbox, props.inbox, '', moveToInboxTitle)

            _.each actionSectionCheckboxes, propStoreFn
            return
        .then ->
          # Constraints section
          Q.all([
            (__msg 'menuConstraintsNoAnswer')
            (__msg 'menuConstraintsNoAnswerTitle')
            (__msg 'menuAdditionalActionsArchive')
            (__msg 'menuAdditionalActionsArchiveTitle')
          ]).then ([noAnswer, noAnswerTitle, archive, archiveTitle]) ->
            log 'compose: constraint section'
            constraintSection = popup.append new GMailUI.Section
            constraintSection.append new GMailUI.Separator
            constraintSectionCheckboxes =
              noanswer: constraintSection.append (new GMailUI.PopupCheckbox noAnswer, props.noanswer, '', noAnswerTitle)
              archive: constraintSection.append (new GMailUI.PopupCheckbox archive, props.archive, '', archiveTitle)

            _.each constraintSectionCheckboxes, propStoreFn
            return
        .then ->
          log 'compose: presets'
          presetMenu = new GMailUI.PopupMenu popup
          presetMenu.addClass M.CLS_MENU
        .then ->
          # Date picker
          __msg('dateFormat').then (dateFormat) ->
            log 'compose: date picker'
            pickerMenu = new GMailUI.PopupMenu popup
            pickerMenu.addClass M.CLS_PICKER

            picker = null
            pickerMenu.onShow = ->
              unless picker
                picker = new Pikaday
                  bound: false
                  format: dateFormat
                  minDate: moment().add(1, 'day').toDate()
                  maxDate: moment().add(1, 'year').toDate()
                  onSelect: ->
                    date = @getMoment()
                    log 'schedule', date.format()
                    schedule date.utc().valueOf()
                    return
                pickerMenu.getElement().append picker.el
              return
            return
        .then =>
          # Time section
          Q.all([
              (__msg 'menuTime')
              (__msg 'menuTimePresetSpecifiedDate')
          ]).then ([menuTime, menuTimePresetSpecifiedDate]) =>
            log 'compose: time section'
            timeSection = popup.append new GMailUI.Section()
            timeSection.append new GMailUI.Separator()
            timeSection.append new GMailUI.PopupLabel menuTime

            timeSection.append new GMailUI.PopupMenuItem pickerMenu, menuTimePresetSpecifiedDate,  '',  '',  true
            timeSection.append new GMailUI.Separator()

            # Presets
            @getPresets().then (presets) =>
              sep = null
              _.each presets, (times, key) =>
                unless _.isEmpty times
                  _.each times, (time) =>
                    timeFn = @generateTimeFn key
                    @getTexts(key, time).then ([label, title]) ->
                      timeSection.append sep if sep
                      item = timeSection.append new GMailUI.Button label, title
                      item.on 'click', ->
                        wen = timeFn time
                        log "schedule: #{time}, #{key}: #{wen}"
                        schedule wen
                        return
                      return
                    return
                  sep = new GMailUI.Separator()
                return
              return
        .then ->
          Q.all([
            (__msg 'extName')
            (__msg 'errorNoActionSpecified')
          ]).then ([extName, noActionSpecified]) ->
            log 'compose: button'
            button = bar.append new GMailUI.ButtonBarPopupButton popup, '', extName
            errorSection = popup.append new GMailUI.ErrorSection noActionSpecified
            isValid()
        .then ->
          log 'compose: return'
          bar.getElement()

    _delta: (offset) ->
      "delta:#{offset}"

    generateTimeFn: (unit) ->
      _1d = 24 * (_1h = 60 * (_1m = 60 * 1000))

      switch unit
        when 'minutes'
          (time) => @_delta (_1m * time)
        when 'hours'
          (time) => @_delta (_1h * time)
        when 'tomorrow'
          (hour) ->
            moment()
              .add(1, 'day')
              .hours(hour)
              .minutes(0)
              .seconds(0)
              .utc()
              .valueOf()
        when 'days'
          (time) => @_delta (_1d * time)
        when 'months'
          (month) ->
            moment().add(month, 'months').utc().valueOf()

    getMessageId: =>
      deferred = Q.defer()
      try
        if @isPreviewPaneEnabled()
          id = @selectedConversationId
        else
          id = /\/([0-9a-f]{16})/i.exec window.location.hash
          id = id?[1]
        deferred.resolve id
      catch e
        deferred.reject e
      deferred.promise

    onSchedule: (props) =>
      deferred = Q.defer()
      @getMessageId()
        .catch (err) =>
          track error: err
          @onScheduleError null, null, err, ''
        .then (messageId) =>
          unless messageId
            __msg('errorNotWithinAConversation')
              .then (notWithinAConversation) =>
                @onScheduleError null, null, notWithinAConversation, ''
            deferred.reject()
          Q.all([
            Q.when(messageId)
            @getVersion()
            @getServiceUrl()
          ]).then ([messageId, version, url]) =>
            data =
              msgId: messageId
              when:  props.when
              version: version

            data.markUnread = true              if !!props.unread
            data.starIt = true                  if !!props.star
            data.onlyIfNoAnswer = true          if !!props.noanswer
            data.moveToInbox = true             if !!props.inbox
            data.archiveAfterScheduling = true  if !!props.archive

            log 'scheduling mail...', data

            url += M.SCHEDULE_SUFFIX
            success = =>
              deferred.resolve()
              ExtensionFacade.showNotification 'shared/images/tie.svg', (__msg 'notificationScheduleSuccessTitle'), (__msg 'notificationScheduleSuccess')
              @activateArchiveButton() if data.archiveAfterScheduling
              return

            error = (status, error, responseText) =>
              deferred.reject()
              @onScheduleError status, data, error, responseText
              return

            ($.post url, data, null, 'json')
            .done (resp, textStatus, jqXHR) ->
              if resp.success
                success()
              else
                error textStatus, resp.error, jqXHR.responseText
              return
            .fail (jqXHR, textStatus, reason) ->
              track [textStatus, reason, jqXHR.responseText]
              error textStatus, reason, jqXHR.responseText
              return
            return
      deferred.promise

    createDialog: (title, okButton, cancelButton) ->
      dialog = new GMailUI.ModalDialog title

      [okButtonLabel, okButtonTooltip] = okButton
      [cancelButtonLabel, cancelButtonTooltip] = cancelButton

      container = dialog.append new GMailUI.ModalDialog.Container()

      footer = dialog.append new GMailUI.ModalDialog.Footer()
      okButton = footer.append new GMailUI.ModalDialog.Button okButtonLabel, okButtonTooltip
      cancelButton = footer.append new GMailUI.ModalDialog.Button cancelButtonLabel, cancelButtonTooltip, 'cancel'

      [dialog, okButton, cancelButton, container, footer]

    welcome: ->
      (__msg 'extName').then (extName) =>
        Q.all([
          (__msg 'welcomeDialogTitle', extName)
          (__msg 'welcomeDialogButtonOk')
          (__msg 'welcomeDialogButtonOkTooltip')
          (__msg 'welcomeDialogButtonCancel')
          (__msg 'welcomeDialogButtonCancelTooltip', extName)
          (__msg 'welcomeDialogText', extName)
          (__msg 'welcomeDialogImageAlt')
          (__msg 'welcomeDialogImageHint')
        ]).then ([_title, _ok, _okTT, _cancel, _cancelTT, _ext, _imgAlt, _imgHint]) ->
          [dialog, okButton, cancelButton, container, footer] = @createDialog _title, [_ok, _okTT], [_cancel, _cancelTT]

          Text = _ext.replace /\n/g, '<br/>'
          imgSrc = ExtensionFacade.getURL 'shared/images/button_example.svg'
          container.append  """
                    <div class="#{M.CLS_WLCM_DLG}">
                      <img src="#{imgSrc}" data-tooltip="#{_imgHint}" alt="#{_imgAlt}" align="right">
                      #{Text}
                    </div>
                    """

          okButton.on 'click', =>
            [authDialog, authOkButton, authCancelButton, authContainer, authFooter] = @gettingStartedDialog()
            container.replaceWith authContainer
            okButton.replaceWith authOkButton
            cancelButton.replaceWith authCancelButton
            dialog.title authDialog.title()

            authOkButton.on 'click', =>
              @openAuthWindow {}
              dialog.close()
              return

            authCancelButton.on 'click', dialog.close

          cancelButton.on 'click', dialog.close
          dialog.open()

    gettingStartedDialogContent: ->
      extName = __msg 'extName'
      img = ExtensionFacade.getURL 'shared/images/authorize.svg'
      dialogText = __msg 'authorizeDialogText', extName
      dialogText = dialogText.replace /\n/g, '<br/>'
      """
      <div class="#{M.CLS_AUTH_TXT}">
        #{dialogText}
      </div>
      <div class="#{M.CLS_AUTH_IMG}">
        <img src="#{img}" data-tooltip="#{__msg 'authorizeDialogImageHint'}" alt="#{__msg 'authorizeDialogImageAlt'}">
      </div>
      """

    gettingStartedDialog: ->
      extName = __msg 'extName'
      [dialog, okButton, cancelButton, container, footer] = @createDialog (__msg 'authorizeDialogTitle', extName), [(__msg 'authorizeDialogButtonOk'), (__msg 'authorizeDialogButtonOkTooltip')], [(__msg 'authorizeDialogButtonCancel'), (__msg 'authorizeDialogButtonCancelTooltip', extName)]
      container.append @gettingStartedDialogContent()
      [dialog, okButton, cancelButton, container, footer]

    gettingStarted: (params) ->
      log 'showing getting started dialog'
      [dialog, okButton, cancelButton, container, footer] = @gettingStartedDialog()

      okButton.on 'click', =>
        @openAuthWindow params
        dialog.close()
        return

      cancelButton.on 'click', dialog.close

      dialog.open()

    openAuthWindow: (params) ->
      @getServiceUrl().then (url) ->
        url += M.SETUP_URL_SUFFIX
        if params
          query = $.param params
          url += "?#{query}"
        windowOptions =
          width: 500
          height: 500
          location: 0
          menubar: 0
          scrollbars: 0
          status: 0
          toolbar: 0
          resizable: 1
        w = window.open url, M.CLS, (($.param windowOptions).replace '&', ',')
        w.focus()
        return
      return

    onScheduleError: (status, params, error, responseText) =>
      log 'There was an error', arguments

      errorCodeAvailable = (_.isObject error) and ('code' of error)
      if (errorCodeAvailable and error.code is'authMissing') or
      (status is 'parsererror' and M.isAuthorisationErrorPage responseText) or
      (M.isAuthorisationErrorResponse status)
        @gettingStarted params
      else
        log 'could not recover, showing error'
        getMessage = ->
          if errorCodeAvailable
            (__msg "notificationScheduleError#{error.code}")
          else
            track [status, params, error, responseText]
            (__msg 'notificationScheduleError', '' + new String error)

        ExtensionFacade.showNotification 'shared/images/tie.svg', (__msg 'notificationScheduleErrorTitle'), getMessage()
      return

  mb = new M()
  return

) jQuery, window, window.ExtensionFacade, window.Q, window.Eventr if top.document is document
