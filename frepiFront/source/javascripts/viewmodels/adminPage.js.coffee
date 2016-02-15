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
		# RESTfulService.makeRequest('DELETE', "/auth/sign_out", '', (error, success, headers) =>
		# 	if error
		# 		console.log 'An error has ocurred'
		# 	else
		# 		Config.destroyLocalStorage()
		# 		window.location.href = '../../login.html'
		# )
		Config.destroyLocalStorage()
		window.location.href = '../../login.html'

	setUserInfo: =>
		tempUser = JSON.parse(Config.getItem('userObject'))
		# @user = ko.mapping.fromJS(tempUser)
		console.log tempUser
		console.log @user	

	setPaginationItemsToShow: (objPage, DOMParent) ->
		numShownPages = objPage.showablePages().length

		# Select which item should be set as active in the pagination list
		module = objPage.activePage % 10
		moduleFive = module % 5

		if module is 0 or moduleFive is 0
			activePage = 5
		else
			if moduleFive is 1 and objPage.activePage isnt 1
				activePage = 6
			else
				activePage = if numShownPages < 10 then module else moduleFive

		# Set a mid point based on the current shown pagination items limits
		midPoint = parseInt((objPage.lowerLimit + objPage.upperLimit)/2)

		unless numShownPages < 10
			if objPage.activePage > midPoint
				objPage.lowerLimit = midPoint
				possibleUpperLimit = objPage.lowerLimit + 10
				if possibleUpperLimit < objPage.allPages.length
					objPage.upperLimit = possibleUpperLimit
				else
					objPage.upperLimit = objPage.allPages.length - 1

		if (objPage.activePage - 1) is objPage.lowerLimit and (objPage.activePage - 1) isnt 0
			objPage.upperLimit = if numShownPages < 10 then objPage.showablePages()[4].num else midPoint
			objPage.lowerLimit = objPage.upperLimit - 10

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
