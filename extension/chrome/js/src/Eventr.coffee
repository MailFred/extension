# Adapted from http://stackoverflow.com/questions/6157929
class Eventr
	@eventMatchers:
		HTMLEvents:		/^(?:load|unload|abort|error|select|change|submit|reset|focus|blur|resize|scroll)$/i
		MouseEvents:	/^(?:click|dblclick|mouse(?:down|up|over|move|out))$/i

	@defaults:
		pointerX: 	0
		pointerY: 	0
		button: 	0
		ctrlKey: 	false
		altKey: 	false
		shiftKey: 	false
		metaKey: 	false
		bubbles: 	true
		cancelable: true
	
	@simulate: (target, eventName, options = {}) ->
		for name,matcher of @eventMatchers
			if matcher.test eventName
				eventType = name
				break

		throw new SyntaxError 'Only HTMLEvents and MouseEvents interfaces are supported' unless eventType
		eventName = eventName.toLowerCase()
		options = _.defaults @defaults, options

		if document.createEvent
			evt = document.createEvent eventType
			switch eventType
				when 'HTMLEvents'
					evt.initEvent eventName, options.bubbles, options.cancelable
				else
					evt.initMouseEvent eventName, options.bubbles, options.cancelable, document.defaultView, options.button, options.pointerX, options.pointerY, options.pointerX, options.pointerY, options.ctrlKey, options.altKey, options.shiftKey, options.metaKey, options.button, target
			target.dispatchEvent evt
		else
			options.clientX = options.pointerX
			options.clientY = options.pointerY
			delete options.pointerX
			delete options.pointerY
			evt = document.createEventObject()
			oEvent = _.extend evt, options
			target.fireEvent "on#{eventName}", oEvent
		
		target