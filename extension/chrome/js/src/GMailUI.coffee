GMailUI = {}

class GMailUI.Breadcrumbs
	@LIST_SEL: 'ol.gbtc'
	@markup: _.template """
						<li class="gbt">
							<a href="#" class="gbgt">
							<span class="gbts">
								<span><%- label %></span>
								<% if(isMenu) { %>
								<span class="gbma"></span>
								<% } %>
							</span>
							</a>
						</li>
						"""
	@add: (label, onClick, isMenu = false) ->
		obj =
			label: label
			isMenu: !!isMenu
		item = 	$ @markup obj
		(item.find '.gbgt').on 'click', onClick if onClick
		item.prependTo $ @LIST_SEL
		item


class GMailUI.ModalDialog
	@BG: 	$ 	"""
				<div class="Kj-JD-Jh" style="opacity: 0.75; width: 2560px; height: 2560px; margin-left: -230px; margin-top: -64px;"></div>
				"""
	@dialog: _.template """
						<div class="Kj-JD" tabindex="0" style="left: 50%; top: 40%; width: 460px; overflow: visible; margin-left: -230px; margin-top: -64px;" role="dialog" aria-labelledby="<%= id %>">
							<div class="Kj-JD-K7 Kj-JD-K7-GIHV4" id="<%= id %>">
								<span class="Kj-JD-K7-K0"><%- title %></span>
								<span class="Kj-JD-K7-Jq" act="close"></span>
							</div>
						</div>
						"""
						###
							<div class="Kj-JD-Jz">
								<div id="ri_selecttimezone_invalid" style="margin-bottom: 15px;display:none">
									<div class="asl T-I-J3 J-J5-Ji" style="margin-bottom: -5px;"></div>
									Invalid Date
								</div>
								<div style="float:left;padding-right:10px">
									<label for="ri_selectdate" class="el">Select date</label>
									<br><input id="ri_selectdate" class="rbx nr">
								</div>
								<div style="float:left;padding-right:10px">
									<label for="ri_selecttime" class="el">
										time <span class="font-gray">(24h format)</span>
									</label>
									<br><input id="ri_selecttime" class="rbx nr" style="width:120px" autocomplete="OFF">
								</div>
								<div style="float:left">
									<label for="ri_selecttimezone" class="el">timezone (optional)</label>
									<br><input id="ri_selecttimezone" class="rbx nr" style="width:120px" autocomplete="OFF">
								</div> 
								<div style="clear:both;"></div>
							</div>
							<div class="Kj-JD-Jl">
								<button id="ri_b2" class="J-at1-atl"> Add reminder </button>
								<button id="ri_b1" class="J-at1-auR"> Cancel </button>
							</div>
						###
						
	@open: (title, onClose) ->
		body = $ 'body'
		@BG.appendTo body
		obj =
			id: 	_.uniqueId 'modalDialog-'
			title: 	title

		dialog = $ @dialog obj
		closeButton = dialog.find "[act='close']"
		closeButton.on 'click', (e) =>
			@BG.detach()
			dialog.remove()
			onClose?()
			return
		dialog.appendTo body
		dialog
	@close: ->

class GMailUI.Helper
	@hover: (target, hoverClass) ->
		target.hover 	((e) ->
							target.addClass hoverClass
							return
						),
						((e) ->
							target.removeClass hoverClass
							return
						)
		return

class GMailUI.UIElement
	constructor: (html) ->
		@setElement html

	element: null
	getElement: -> @element
	setElement: (e) ->
		if _.isString e or _.isElement e
			@element = $ e
		else
			@element = e
		@element

	addClass: ->
		@element.addClass.apply @element, arguments
		return

	removeClass: ->
		@element.removeClass.apply @element, arguments
		return

	css: ->
		@element.css.apply @element, arguments
		return					

	show: ->
		@element.show()
		return

	hide: ->
		@element.hide()
		return

	toggle: ->
		@element.toggle.apply @element, arguments
		return

class GMailUI.Container extends GMailUI.UIElement
	constructor: (@container) ->

	setContainer: (@container) ->
	getContainer: -> @container

	append: (e) ->
		if e instanceof GMailUI.UIElement
			@container.append e.getElement()
		else if _.isElement
			@container.append e
		else
			throw 'Unknown element'
		e

class GMailUI.ButtonBar extends GMailUI.Container
	constructor: ->
		super @setElement	"""
							<div class="G-Ni J-J5-Ji">
							"""

class GMailUI.OnAble extends GMailUI.UIElement
	constructor: (hoverClass, @selectedClass) ->
		GMailUI.Helper.hover @getElement(), hoverClass

	toggle: (target, selected) ->
		target.toggleClass @selectedClass, selected
		target.attr 'aria-checked', if selected then 'true' else 'false'
		return

	setSelected: (selected, exclusive = false) ->
		throw 'Not available for this element' if not @selectedClass
		target = @getElement()
		@toggle target, selected
		if exclusive and selected
			@toggle target.siblings(), false
		return

	# Toggling checkboxes
	addOnChange: (onChange, exclusive = false) ->
		throw 'Not available for this element' if not @selectedClass
		@on 'click', (e) =>
			e = @getElement()
			checked = e.hasClass @selectedClass

			# We can't deselect the selected item if we are in exclusive mode
			return if exclusive and checked

			if @menu instanceof GMailUI.PopupMenuItem
				@menu.setSelected !checked, true
			
			@setSelected !checked, exclusive
			onChange? e, !checked
			return
		return

	on: (type, f) =>
		element = @getElement()
		element.on.apply element, arguments

class GMailUI.Button extends GMailUI.OnAble
	@template: _.template	"""
							<div class="J-JK" role="menuitem" style="-webkit-user-select: none;">
								<div class="J-JK-Jz"
									<% if(tooltip) { %>
										data-tooltip="<%- tooltip %>"
										aria-label="<%- tooltip %>"
									<% } %>
									<% if(title) { %>
										title="<%- title %>"
									<% } %>
									style="-webkit-user-select: none;">
									<%- label %>
								</div>
							</div>
							"""
	@hoverClass: 'J-JK-JT'

	constructor: (label, tooltip = '', title = '') ->
		obj =
			label:		label
			tooltip:	tooltip
			title:		title
		element = @setElement GMailUI.Button.template obj
		super GMailUI.Button.hoverClass

class GMailUI.ButtonBarButton extends GMailUI.OnAble
	@template: 	_.template 	"""
							<div class="T-I J-J5-Ji T-I-Js-IF ar7 ns T-I-ax7 L3" 
								<% if(tooltip) { %>
									data-tooltip="<%- tooltip %>"
									aria-label="<%- tooltip %>"
								<% } %>
								<% if(title) { %>
									title="<%- title %>"
								<% } %>
								role="button" tabindex="0" style="-webkit-user-select: none;">
								<div class="asa">
									<span class="J-J5-Ji ask">&nbsp;</span>
									<div class="ase T-I-J3 J-J5-Ji"></div>
								</div>
								<div class="G-asx T-I-J3 J-J5-Ji">&nbsp;</div>
							</div>
							"""
	@hoverClass: 'T-I-JW'
	@pushedClass: 'T-I-Kq'

	constructor: (label, tooltip = '', title = '') ->
		obj =
			label:		label
			tooltip:	tooltip
			title:		title
		element = @setElement GMailUI.ButtonBarButton.template obj

		super GMailUI.ButtonBarButton.hoverClass

		# Don't focus the item when clicking on it
		element.on 'mousedown', (e) ->
			e.preventDefault()
			return

		element.on 'click', (e) ->
			e.stopPropagation()
			return

class GMailUI.ButtonBarPopupButton extends GMailUI.ButtonBarButton
	@expandedClass: 'T-I-Kq'

	constructor: (@popup, label, tooltip = '', title = '') ->
		super label, tooltip, title
		element = @getElement()

		# this button has a popup
		element.attr 'aria-haspopup', 'true'

		@on 'click', (e) =>
			unless @popup.isAdded
				# Add the popup markup to the DOM
				target = element.parent().parent()
				target.append @popup.getElement() if @popup.isAdded = (target.length > 0)

			if @popup.getElement().is ':visible'
				# Popup is visible, so close it
				@close()
			else
				# As long as the popup is open, clicks anywhere else should close it
				($ 'body').on 'click', @close

				# Add the pushed state to the button
				element.addClass GMailUI.ButtonBarPopupButton.expandedClass
				element.attr 'aria-expanded', 'true'

				# Set the position of the popup menu right beneath the menu button (lower left corner)
				@popup.css
					left: 	element.parent().position().left
					top:	element.outerHeight()

				# and show it :-)
				@popup.show()

	# Close the popup
	close: =>
		# Disable the body listener
		($ 'body').off 'click', @close

		element = @getElement()
		# Remove the pushed state from the menu button
		element.removeClass GMailUI.ButtonBarPopupButton.expandedClass
		element.attr 'aria-expanded', 'false'

		# hide the popup
		@popup.hide()

class GMailUI.Popup extends GMailUI.Container
	constructor: ->
		element = @setElement 	"""
								<div class="J-M agd jQjAxd J-M-ayU aCP" style="display: none; -webkit-user-select: none;" role="menu" aria-haspopup="true" aria-activedescendant="">
									<div class="SK AX" style="-webkit-user-select: none;">
									</div>
								</div>
								"""
		super element.children()

		# Clicks on popup itself do not close it either
		element.on 'click', (e) ->
			e.stopPropagation()
			return

class GMailUI.PopupLabel extends GMailUI.UIElement
	@template: _.template 	"""
							<div class="J-awr J-awr-JE" aria-disabled="true" style="-webkit-user-select: none; "><%- label %></div>
							"""
	constructor: (label) ->
		obj =
			label: label
		element = @setElement GMailUI.PopupLabel.template obj

class GMailUI.PopupMenuItem extends GMailUI.OnAble
	@template: _.template	"""
							<div class="J-N J-Ks" role="menuitemcheckbox"
								<% if(tooltip) { %>
									data-tooltip="<%- tooltip %>"
									aria-label="<%- tooltip %>"
								<% } %>
								<% if(title) { %>
									title="<%- title %>"
								<% } %>
								style="-webkit-user-select: none; " aria-checked="false">
								<div class="J-N-Jz">
									<div class="J-N-Jo"></div>
									<%- label %>
									<% if(hasChildren) { %>
									<span class="J-Ph-hFsbo"></span>
									<% } %>
								</div>
							</div>
							"""

	@hoverClass: 'J-N-JT'
	@selectedClass: 'J-Ks-KO'

	constructor: (@menu, label, tooltip = '', title = '', hasChildren = false) ->
		obj =
			label:			label
			tooltip:		tooltip
			title:			title
			hasChildren:	hasChildren
		element = @setElement GMailUI.PopupMenuItem.template obj

		super GMailUI.PopupMenuItem.hoverClass, GMailUI.PopupMenuItem.selectedClass

		# Don't focus the item when clicking on it
		element.on 'mousedown', (e) ->
			e.preventDefault()
			return
		
		if @menu instanceof GMailUI.PopupMenu
			id = _.uniqueId 'PopupMenuItem-'
			element.attr 'id', id

			element.hover 	((e) =>
								unless @menu.isAdded
									# Add the popup markup to the DOM
									target = @getMenuTarget().parent()
									target.append @menu.getElement() if @menu.isAdded = (target.length > 0)

								@menu.getElement().attr 'aria-activedescendant', id
								@menu.inMenu = true
								x = =>
									return unless @menu.inMenu
									@reposition()
									@menu.show()
									return

								_.delay x, @menu.delay
								return),
							((e) =>
								@menu.inMenu = false
								_.delay @menu.hideMenu, @menu.delay
								return)

	getMenuTarget: ->
		@menu.parent.getElement()
	reposition: =>
		element = @getElement()
		popup = @getMenuTarget()
		ppos = popup.position()
		@menu.css
			top: 	element.position().top + ppos.top
			left: 	ppos.left + popup.outerWidth()
		return

class GMailUI.Section extends GMailUI.Container
	constructor: ->
		super @setElement 	"""
							<div style="-webkit-user-select: none;"></div>
							"""

class GMailUI.Separator extends GMailUI.UIElement
	constructor: ->
		@setElement """
					<div class="J-Kh" style="-webkit-user-select: none;" role="separator"></div>
					"""

class GMailUI.ErrorSection extends GMailUI.Section
	@template: _.template	"""
							<div class="asd ja" style="-webkit-user-select: none; ">
								<%- message %>
							</div>
							"""
	constructor: (message) ->
		super()
		element = @getElement()
		element.addClass 'b7o7Ic'
		@append new GMailUI.Separator
		obj =
			message: message
		@setContainer element.append $ GMailUI.ErrorSection.template obj

	setMessage: (message) ->
		@getContainer().html message
		return

class GMailUI.PopupMenu extends GMailUI.Container
	@template:	"""
				<div class="J-M J-M-ayU" style="-webkit-user-select: none; display: none; " role="menu" aria-haspopup="true" aria-activedescendant="">
				</div>
				"""

	delay:		300
	inMenu:		false

	constructor: (@parent) ->
		super @setElement $ GMailUI.PopupMenu.template
		element = @getElement()

		# Clicks on menu do not close the popup
		element.on 'click', (e) ->
			e.stopPropagation()
			return

		element.hover ((e) => 
						@inMenu = true
						return),
					((e) =>
						@inMenu = false
						_.delay @hideMenu, @delay
						return)
	hideMenu: =>
		return if @inMenu
		@close()
		return

	close: ->
		@getElement().attr 'aria-activedescendant', null
		@hide()
		return


class GMailUI.RawHTML extends GMailUI.UIElement
	constructor: (html) ->
		super html

class GMailUI.PopupCheckbox extends GMailUI.OnAble
	@template: _.template 	"""
							<div class="J-LC" aria-checked="false" role="menuitem"
								<% if(tooltip) { %>
									data-tooltip="<%- tooltip %>"
									aria-label="<%- tooltip %>"
								<% } %>
								<% if(title) { %>
									title="<%- title %>"
								<% } %>
								style="-webkit-user-select: none;">
								<div class="J-LC-Jz" style="-webkit-user-select: none;">
									<div class="J-LC-Jo J-J5-Ji" style="-webkit-user-select: none;"></div><%- label %>
								</div>
							</div>
							"""

	@hoverClass: 	'J-LC-JT'
	@selectedClass: 'J-LC-JR-Jp'

	constructor: (label, selected = false, tooltip = '', title = '') ->
		obj =
			label:		label
			title: 		title
			tooltip: 	tooltip

		element = @setElement GMailUI.PopupCheckbox.template obj

		super GMailUI.PopupCheckbox.hoverClass, GMailUI.PopupCheckbox.selectedClass
		@setSelected selected