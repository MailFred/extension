
address = window.location.href

if -1 is address.indexOf 'mail.google.com'
	alert 'Not within GMail'
	return
else
  catPos = address.lastIndexOf '#'
  slashPos = address.lastIndexOf '/'
  if catPos > slashPos
  	alert 'Not within a message!'
  	return
  else
  	messageId = address.substr (1 + slashPos)
  	link = "https://script.google.com/a/macros/feth.com/s/AKfycbzxbhXkKUnJ4B-umyZSllwqTGklp0Y9CpzjNlBcy0CKV24TAPQ/exec"
  	window.open "#{link}?messageId=#{messageId}", 'mailbutler', 'width=300,height=200,location=0,menubar=0,scrollbars=0,status=0,toolbar=0,resizable=1'