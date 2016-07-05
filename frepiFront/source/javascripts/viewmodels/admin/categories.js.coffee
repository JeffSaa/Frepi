class CategoriesVM extends AdminPageVM
	constructor: ->
		super()
		@shouldShowCategoriesAlert = ko.observable(true)
		@cateogoriesAlertText = ko.observable()
		@currentCategories = ko.observableArray()
		@currentSubcategories = ko.observableArray()
		@chosenCategory =
			id : ko.observable()
			name : ko.observable()
		@chosenSubcategory =
			id : ko.observable()
			name : ko.observable()

		@categoriesPages =
			allPages: []
			activePage: 0
			lowerLimit: 0
			upperLimit: 0
			showablePages: ko.observableArray()

		# Methods to execute on instance
		# @setExistingSession()
		# @setUserInfo()
		@fetchCategories()
		@setRulesValidation()
		@setDOMProperties()

	createCategory: ->
		$form = $('.create.modal form')
		data =
			email: $form.form('get value', 'email')
			identification: $form.form('get value', 'cc')
			lastName: $form.form('get value', 'lastName')
			firstName: $form.form('get value', 'firstName')
			phoneNumber: $form.form('get value', 'phoneNumber')
			shopperType: $form.form('get value', 'shopperType')

		if $form.form('is valid')
			$('.create.modal form .green.button').addClass('loading')
			RESTfulService.makeRequest('POST', "/categories", data, (error, success, headers) =>
					$('.create.modal form .green.button').removeClass('loading')
					if error
						console.log 'An error has ocurred in the creation of the shopper.'
						console.log error
					else
						console.log success
						Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
						@currentCategories.push(success)
						$('.create.modal').modal('hide')
				)

	createSubcategory: ->
		$form = $('.create.modal form')
		categoryId = $form.form('get value', 'categoryID')
		data =
			name: $form.form('get value', 'name')
			category_id: categoryId

		if $form.form('is valid')
			$('.create.modal form .green.button').addClass('loading')
			RESTfulService.makeRequest('POST', "/categories/#{categoryId}/subcategories", data, (error, success, headers) =>
					$('.create.modal form .green.button').removeClass('loading')
					if error
						console.log 'An error has ocurred in the creation of the shopper.'
						console.log error
					else
						console.log success
						Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
						@currentCategories.push(success)
						$('.create.modal').modal('hide')
				)

	updateCategory: ->
		$form = $('.update.modal form')
		data =
			email: $form.form('get value', 'email')
			identification: $form.form('get value', 'cc')
			lastName: $form.form('get value', 'lastName')
			firstName: $form.form('get value', 'firstName')
			phoneNumber: $form.form('get value', 'phoneNumber')
			shopperType: $form.form('get value', 'shopperType')

		if $form.form('is valid')
			$('.update.modal form .green.button').addClass('loading')
			RESTfulService.makeRequest('PUT', "/categories/#{@chosenCategory.id()}", data, (error, success, headers) =>
					$('.update.modal form .green.button').removeClass('loading')
					if error
						console.log 'An error has ocurred in the creation of the admin.'
						console.log error
					else
						console.log success
						Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
						$('.update.modal').modal('hide')
						@fetchCategories()
				)

	updateSubcategory: ->
		$form = $('.update.modal form')
		data =
			name: $form.form('get value', 'email')
			category_id: $form.form('get value', 'categoryID')

		if $form.form('is valid')
			$('.update.modal form .green.button').addClass('loading')
			RESTfulService.makeRequest('PUT', "/categories/#{@chosenCategory.id()}", data, (error, success, headers) =>
					$('.update.modal form .green.button').removeClass('loading')
					if error
						console.log 'An error has ocurred in the creation of the admin.'
						console.log error
					else
						console.log success
						Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
						$('.update.modal').modal('hide')
						@fetchCategories()
				)

	deleteCategory: =>
		$('.delete.modal .green.button').addClass('loading')
		RESTfulService.makeRequest('DELETE', "/categories/#{@chosenCategory.id()}", '', (error, success, headers) =>
			$('.delete.modal .green.button').removeClass('loading')
			if error
				console.log 'An error has ocurred while fetching the subcategories!'
			else
				console.log success
				@currentCategories.remove( (shopper) =>
						return shopper.id is @chosenCategory.id()
					)
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
				$('.delete.modal').modal('hide')
		)

	deleteSubcategory: =>
		$('.delete.modal .green.button').addClass('loading')
		RESTfulService.makeRequest('DELETE', "/categories/#{@chosenSubcategory.id()}", '', (error, success, headers) =>
			$('.delete.modal .green.button').removeClass('loading')
			if error
				console.log 'An error has ocurred while fetching the subcategories!'
			else
				console.log success
				@currentSubcategories.remove( (shopper) =>
						return shopper.id is @chosenSubcategory.id()
					)
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
				$('.delete.modal').modal('hide')
		)

	showUpdate: (shopper) =>
		@chosenCategory.id(shopper.id)
		$('.update.modal form')
			.form('set values',
					email					: shopper.email
					cc 				 	  : shopper.identification
					lastName		  : shopper.lastName
					firstName			: shopper.firstName
					phoneNumber 	: shopper.phoneNumber
					shopperType		: shopper.shopperType
				)
		$('.update.modal').modal('show')

	showDelete: (shopper) =>
		@chosenCategory.id(shopper.id)
		@chosenCategory.name(shopper.firstName+' '+shopper.lastName)
		$('.delete.modal').modal('show')

	setPrevShopperPage: ->
		if @categoriesPages.activePage is 1
			nextPage = @categoriesPages.allPages.length - 1
		else
			nextPage = @categoriesPages.activePage - 1

		@fetchCategoriesPage({num: nextPage})

	setNextShopperPage: ->
		if @categoriesPages.activePage is @categoriesPages.allPages.length - 1
			nextPage = 1
		else
			nextPage = @categoriesPages.activePage + 1

		@fetchCategoriesPage({num: nextPage})

	fetchCategoriesPage: (page) =>
		@categoriesPages.activePage = page.num
		@setPaginationItemsToShow(@categoriesPages, 'table.categories')
		@fetchCategories(page.num)

	fetchCategories: (numPage = 1) ->
		@isLoading(true)
		data =
			page : numPage

		RESTfulService.makeRequest('GET', "/categories", data, (error, success, headers) =>
			@isLoading(false)
			if error
				console.log 'An error has ocurred while fetching the categories!'
				@shouldShowCategoriesAlert(true)
				@cateogoriesAlertText('Hubo un problema buscando la información de los categories')
			else
				console.log success
				if success.length > 0
					if @categoriesPages.allPages.length is 0
						totalPages = Math.ceil(headers.totalItems/10)
						@categoriesPages.allPages.push({num: i+1}) for i in [0..totalPages]
						@categoriesPages.activePage = 1
						@categoriesPages.lowerLimit = 0
						@categoriesPages.upperLimit = if totalPages < 10 then totalPages else 10
						@categoriesPages.showablePages(@categoriesPages.allPages.slice(@categoriesPages.lowerLimit, @categoriesPages.upperLimit))

						$("table.categories .pagination .pages .item:first-of-type").addClass('active')
					@currentCategories(success)
					@shouldShowCategoriesAlert(false)
				else
					@shouldShowCategoriesAlert(true)
					@cateogoriesAlertText('No hay categories')

				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
		)

	fetchSubcategories: (categoryID) ->
		$('.subcategories .dropdown').addClass('loading')
		RESTfulService.makeRequest('GET', "/categories/#{categoryID}/subcategories", '', (error, success, headers) =>
			$('.subcategories .dropdown').removeClass('loading')
			if error
				console.log 'An error has ocurred while fetching the subcategories!'
			else
				@currentSubcategories(success)
		)

	setRulesValidation: ->
		emptyRule =
			type: 'empty'
			prompt: 'No puede estar vacío'
		$('.ui.modal form')
			.form({
					fields:
						cc:
							identifier: 'cc'
							rules: [emptyRule]
						firstName:
							identifier: 'firstName'
							rules: [emptyRule]
						lastName:
							identifier: 'lastName'
							rules: [emptyRule]
						phoneNumber:
							identifier: 'phoneNumber'
							rules: [emptyRule]
						email:
							identifier: 'email'
							rules: [
								{
									type: 'email'
									prompt: 'Ingrese un email válido'
								}
							]
						shopperType:
							identifier: 'shopperType'
							rules: [emptyRule]
					inline: true
					keyboardShortcuts: false
				})

	setDOMProperties: ->
		$('.ui.modal')
			.modal(
					onHidden: ->
						$('.ui.modal form').form('clear') # Clears form when the modal is hidding
				)

		$('.subcategories .dropdown')
			.dropdown(
				onChange: (value, text, $selectedItem) =>
					@fetchSubcategories(value)
			)

categories = new CategoriesVM
ko.applyBindings(categories)
