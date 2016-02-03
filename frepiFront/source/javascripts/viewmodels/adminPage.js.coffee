class window.AdminPageVM
	constructor: ->
		@shouldShowError = ko.observable(false)
		@isLoading = ko.observable(true)
		@user = JSON.parse(Config.getItem('userObject'))

		# Methods to execute on instance
		# @setExistingSession()
		# @setUserInfo()
		@setDOMElements()

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

	setPaginationItemToShow: (activeNumPage, objPage, table) ->
		numShownPages = objPage.showablePages().length

		# Select which item should be set as active in the pagination list
		module = activeNumPage % 10
		moduleFive = module % 5

		if module is 0 or moduleFive is 0
			activePage = 5
		else
			if moduleFive is 1 and activeNumPage isnt 1
				activePage = 6
			else
				activePage = moduleFive

		midPoint = parseInt((objPage.lowerLimit + objPage.upperLimit)/2)

		unless numShownPages < 10
			if activeNumPage > midPoint
				objPage.lowerLimit = midPoint
				possibleUpperLimit = objPage.lowerLimit + 10
				if possibleUpperLimit < objPage.allPages.length
					objPage.upperLimit = possibleUpperLimit
				else
					objPage.upperLimit = objPage.allPages.length - 1

		if (activeNumPage - 1) is objPage.lowerLimit and (activeNumPage - 1) isnt 0
			objPage.upperLimit = if numShownPages < 10 then objPage.showablePages()[4].num else midPoint
			objPage.lowerLimit = objPage.upperLimit - 10

		# Set new available pages in the pagination list
		objPage.showablePages(objPage.allPages.slice(objPage.lowerLimit, objPage.upperLimit))

		# Set new active page
		$("#{table} .pagination .pages .item").removeClass('active')
		$("#{table} .pagination .pages .item:nth-of-type(#{activePage})").addClass('active')

	setDOMElements: ->
		$('.ui.create.modal')
			.modal('attach events', '.create.button', 'show')
