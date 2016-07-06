class window.AdminPageVM
	constructor: ->
		@shouldShowError = ko.observable(false)
		@isLoading = ko.observable(true)
		@user = JSON.parse(Config.getItem('userObject'))

		# Methods to execute on instance
		# @setExistingSession()
		# @setUserInfo()
		@setDOMElements()
		@setDOMEventsHandlers()

	logout: ->
		RESTfulService.makeRequest('DELETE', "/auth/sign_out", '', (error, success, headers) =>
			if error
				console.log 'An error has ocurred'
			else
				Config.destroyLocalStorage()
				window.location.href = '../login.html'
		)
		# Config.destroyLocalStorage()
		# window.location.href = '../login.html'

	setUserInfo: =>
		tempUser = JSON.parse(Config.getItem('userObject'))
		# @user = ko.mapping.fromJS(tempUser)
		console.log tempUser
		console.log @user

	setPaginationItemsToShow: (objPage, DOMParent) ->
		numShownPages = objPage.showablePages().length

		# Select which item should be set as active in the pagination list
		#console.log objPage
		#console.log "Active page => #{objPage.activePage}"
		module = objPage.activePage % 10

		activePage = module
		if activePage is 0
			activePage = objPage.showablePages().length

		lessThanLimit = false
		if (objPage.activePage <= objPage.lowerLimit and objPage.activePage isnt 1) or objPage.activePage == (objPage.allPages.length - 1)
			lessThanLimit = true

		if objPage.activePage == objPage.lowerLimit + 1
			$("#{DOMParent} .pagination .pages .item").removeClass('active')
			$("#{DOMParent} .pagination .pages .item:nth-of-type(#{1})").addClass('active')
			return

		#console.log "Less than limit => #{lessThanLimit}"

		if lessThanLimit
			if objPage.activePage == (objPage.allPages.length - 1)
				objPage.lowerLimit = (objPage.allPages.length - 1) - activePage
				objPage.upperLimit = objPage.activePage
			else
				objPage.lowerLimit -= 10
				objPage.upperLimit = objPage.lowerLimit + 10
				activePage = 10
		else
			# unless numShownPages < 10
				#console.log "Has more than 10 pages"
			if module is 1
				possibleUpperLimit = objPage.upperLimit + 10
				objPage.lowerLimit = if objPage.activePage is 1 then 0 else objPage.lowerLimit += 10

				if possibleUpperLimit >= objPage.allPages.length
					totalPages = objPage.allPages.length - 1
					if objPage.activePage is 1
						objPage.upperLimit = if totalPages < 10 then totalPages else 10
					else
						objPage.upperLimit = totalPages
				else
					objPage.upperLimit = possibleUpperLimit

		# Set new available pages in the pagination list
		objPage.showablePages(objPage.allPages.slice(objPage.lowerLimit, objPage.upperLimit))

		# Set new active page
		$("#{DOMParent} .pagination .pages .item").removeClass('active')
		$("#{DOMParent} .pagination .pages .item:nth-of-type(#{activePage})").addClass('active')

	setDOMEventsHandlers: ->
		$('.ui.create.button').on('click', ->
				$('.ui.create.modal').modal('show')
			)
		$('.ui.modal .cancel.button').on('click', ->
				$('.ui.modal').modal('hide')
			)

	setDOMElements: ->
		$('.ui.modal .dropdown').dropdown()
