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
		console.log objPage
		console.log "Active page => #{objPage.activePage}"
		module = objPage.activePage % 10
		moduleFive = module % 5


		activePage = module
		if activePage is 0
			activePage = objPage.showablePages().length

		# Set a mid point based on the current shown pagination items limits
		midPoint = parseInt((objPage.lowerLimit + objPage.upperLimit)/2)


		lessThanLimit = false
		if objPage.activePage <= objPage.lowerLimit
			lessThanLimit = true

		console.log "Less than limit => #{lessThanLimit}"

		if lessThanLimit
			objPage.lowerLimit -= 10
			objPage.upperLimit -= 10
		else
			unless numShownPages < 10
				console.log "Has more than 10 pages"
				if module is 1
					objPage.lowerLimit += 10
					possibleUpperLimit = objPage.lowerLimit + 10
					console.log "Possible => #{possibleUpperLimit}"
					if possibleUpperLimit > objPage.allPages.length
						console.log "iF 1"
						objPage.upperLimit = numShownPages
					else
						console.log "iF 2"
						objPage.upperLimit = possibleUpperLimit

		console.log "Limits => #{objPage.lowerLimit} : #{objPage.upperLimit}"

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
