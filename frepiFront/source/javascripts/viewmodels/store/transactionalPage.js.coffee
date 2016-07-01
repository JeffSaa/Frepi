class window.TransactionalPageVM
	constructor: ->
		@session =
			currentStore				: null
			stringToSearch			: null
			currentSucursal			: null
			currentDeparmentID	: null
			currentSubcategorID	: null
			categories					: ko.observableArray([])
			signedUp						: ko.observable()
			sucursals						: ko.observableArray([])
			currentOrder:
				numberProducts	: ko.observable()
				products 				: ko.observableArray([])
				price 					: ko.observable()
				sucursalId			: null
		@user =
			id 							: null
			provider				: null
			discount				: ko.observable()
			email 					: ko.observable()
			name 						: ko.observable()
			firstName 			: ko.observable()
			lastName 				: ko.observable()
			phone 					: ko.observable()
			profilePicture 	: ko.observable()
			fullName 				: ko.observable()

		# Modal variables
		@selectedProduct = null
		@selectedProductCategory = ko.observable()
		@selectedProductImage = ko.observable()
		@selectedProductName = ko.observable()
		@selectedProductPrice = ko.observable()
		@selectedProductSize = ko.observable()
		@selectedProductDescription = ko.observable()

		@errorTextSignUp = ko.observable()

		@isLogged = ko.observable(false)
		@shouldShowDiscountMessage = ko.observable(false)

		@setUserInfo()
		@setRulesValidation()
		# @setDOMElems()

	searchInput: =>
		valueInput = $('#product-searcher').form('get value', 'value')
		@session.stringToSearch = valueInput
		@saveOrder()
		window.location.href = '../store/search.html'

	checkout: =>
		if @user.id isnt null
			if @session.currentOrder.products().length > 0
				orderToPay =
					price: @session.currentOrder.price()
					products: @session.currentOrder.products()
					sucursalId: @session.currentOrder.sucursalId
				console.log orderToPay
				Config.setItem('orderToPay', JSON.stringify(orderToPay))
				window.location.href = '../checkout.html'
			else
				console.log 'There is nothing in the cart...'
		else
			$('#shopping-cart .checkout').addClass('hide')
			$('#shopping-cart .sign-up-banner').addClass('show')

	# Returns null or a product if is currently in the cart
	getProductByID: (id) ->
		for product in @session.currentOrder.products()
			return product if product.id is id
		return null

	chooseStore: (store) ->
		ko.mapping.fromJS(store, @session.currentSucursal)
		$('#choose-store').modal('hide')

	chooseDeparment: (subdeparment) =>
		console.log subdeparment
		if subdeparment.categoryId
			@session.currentDeparmentID = subdeparment.categoryId
			@session.currentSubcategorID = subdeparment.id
		else
			@session.currentDeparmentID = subdeparment.id
			@session.currentSubcategorID = null
		@saveOrder()
		window.location.href = '../store/deparment.html'

	showTextArea: (data, event) ->
		$noteLabel = $(event.currentTarget)
		$textArea = $(event.currentTarget).parent().children('textarea')
		$saveComment = $(event.currentTarget).parent().children('.save.comment')

		$noteLabel.css('display', 'none')
		$textArea.css('display', 'block')
		$saveComment.css('display', 'inline-block')

	addComment: (product, event) ->
		$noteLabel = $(event.currentTarget).parent().children('.note.label')
		$textArea = $(event.currentTarget).parent().children('textarea')
		$saveComment = $(event.currentTarget)
		textareaValue = $textArea.val()

		oldProduct = product
		newProduct =
			comment: textareaValue
			frepiPrice: product.frepiPrice
			id: product.id
			image: product.image
			name: product.name
			quantity: product.quantity
			subcategoryId: product.subcategoryId
			totalPrice: parseInt(product.frepiPrice)

		@session.currentOrder.products.replace(oldProduct, newProduct)
		@saveOrder()

		$noteLabel.css('display', 'inline-block')
		$textArea.css('display', 'none')
		$saveComment.css('display', 'none')

	showInputField: ->
		$('.modal .input.field').addClass('show')
		$('.modal .dropdown.field').addClass('hide')

	addProductModal: ->
		isntInputFieldShown = $('.modal .input.field').attr('class').split(' ').indexOf('show') is -1
		if isntInputFieldShown
			if $('#product-desc form').form('get value', 'quantityDropdown')
				quantity = $('#product-desc form').form('get value', 'quantityDropdown')
				@addToCart(@selectedProduct, parseInt(quantity))
				$('#product-desc').modal('hide')
		else
			if $('#product-desc form').form('get value', 'quantity') > 0
				quantity = $('#product-desc form').form('get value', 'quantity')
				@addToCart(@selectedProduct, parseInt(quantity))
				$('#product-desc').modal('hide')

	addToCart: (productToAdd, quantitySelected) =>
		product = @getProductByID(productToAdd.id)
		quantitySelected = parseInt(quantitySelected)

		if not isNaN(quantitySelected)
			if !product
				@session.currentOrder.products.push(
					comment: ""
					frepiPrice: productToAdd.frepiPrice or productToAdd.frepi_price
					id: productToAdd.id
					image: productToAdd.image
					name: productToAdd.name
					size: productToAdd.size
					quantity: quantitySelected
					subcategoryId: productToAdd.subcategoryId
					totalPrice: parseInt(productToAdd.frepiPrice or productToAdd.frepi_price) * quantitySelected
				)
				$("##{productToAdd.id} .image .label .quantity").text(quantitySelected)
				$("##{productToAdd.id} .image .label").addClass('show')
			else
				oldProduct = product
				newProduct =
					comment: oldProduct.comment
					frepiPrice: oldProduct.frepiPrice or oldProduct.frepi_price
					id: oldProduct.id
					image: oldProduct.image
					name: oldProduct.name
					size: oldProduct.size
					quantity: oldProduct.quantity + quantitySelected
					subcategoryId: oldProduct.subcategoryId
					totalPrice: parseInt(((oldProduct.frepiPrice or oldProduct.frepi_price)*(oldProduct.quantity+quantitySelected)))

				@session.currentOrder.products.replace(oldProduct, newProduct)
				$("##{productToAdd.id} .image .label .quantity").text(oldProduct.quantity + quantitySelected)

			@session.currentOrder.price(parseInt((@session.currentOrder.price() + (productToAdd.frepiPrice or productToAdd.frepi_price)*quantitySelected)))


			if @session.currentOrder.products().length isnt 1
				@session.currentOrder.numberProducts("#{@session.currentOrder.products().length} items")
			else
				@session.currentOrder.numberProducts("1 item")

			@saveOrder()

	logout: ->
		RESTfulService.makeRequest('DELETE', "/auth/sign_out", '', (error, success, headers) =>
			if error
				console.log 'An error has ocurred'
			else
				Config.destroyLocalStorage()
				window.location.href = '../index.html'
		)

	saveOrder: ->
		session =
			categories: @session.categories()
			currentStore: ko.mapping.toJS(@session.currentStore)
			currentSucursal: ko.mapping.toJS(@session.currentSucursal)
			stringToSearch: @session.stringToSearch
			currentDeparmentID: @session.currentDeparmentID
			currentSubcategorID: @session.currentSubcategorID
			signedUp: @session.signedUp()
			sucursals: @session.sucursals()
			currentOrder:
				numberProducts: @session.currentOrder.numberProducts()
				products: @session.currentOrder.products()
				price: @session.currentOrder.price()
				sucursalId: @session.currentOrder.sucursalId

		Config.setItem('currentSession', JSON.stringify(session))

	store: ->
		@saveOrder()
		window.location.href = '../store/index.html'

	removeFromCart: (product) ->
		if product.quantity is 1
			@removeItem(product)
		else
			oldProduct = product
			newProduct =
				comment: oldProduct.comment
				frepiPrice: oldProduct.frepiPrice or oldProduct.frepi_price
				id: oldProduct.id
				image: oldProduct.image
				name: oldProduct.name
				quantity: oldProduct.quantity - 1
				subcategoryId: oldProduct.subcategoryId
				totalPrice: parseInt(((oldProduct.frepiPrice or oldProduct.frepi_price)*(oldProduct.quantity-1)))

			$("##{product.id} .image .label .quantity").text(oldProduct.quantity - 1)
			@session.currentOrder.products.replace(oldProduct, newProduct)
			@session.currentOrder.price(parseInt((@session.currentOrder.price() - (product.frepiPrice or product.frepi_price))))
			@saveOrder()

	removeItem: (item) ->
		console.log item
		@session.currentOrder.price(parseInt((@session.currentOrder.price() - item.totalPrice)))
		@session.currentOrder.products.remove(item)
		$("##{item.id} .image .label").removeClass('show')

		if @session.currentOrder.products().length isnt 1
			@session.currentOrder.numberProducts("#{@session.currentOrder.products().length} items")
		else
			@session.currentOrder.numberProducts("1 item")

		@saveOrder()

	setCartItemsLabels: ->
		for product in @session.currentOrder.products()
			$("##{product.id} .image .label .quantity").text(product.quantity)
			$("##{product.id} .image .label").addClass('show')

	setExistingSession: ->
		session = Config.getItem('currentSession')

		if session
			session = JSON.parse(Config.getItem('currentSession'))
			@session.currentStore = ko.mapping.fromJS(session.currentStore)
			@session.currentSucursal = ko.mapping.fromJS(session.currentSucursal)
			@session.currentDeparmentID = session.currentDeparmentID
			@session.currentSubcategorID = session.currentSubcategorID
			@session.stringToSearch = session.stringToSearch
			@session.categories(session.categories)
			@session.sucursals(session.sucursals)
			@session.signedUp(session.signedUp)
			@session.currentOrder.numberProducts(session.currentOrder.numberProducts)
			@session.currentOrder.products(session.currentOrder.products)
			@session.currentOrder.price(session.currentOrder.price)
			@session.currentOrder.sucursalId = session.currentOrder.sucursalId
			@setDOMElems()
		else
			@session.currentStore = ko.mapping.fromJS(DefaultModels.STORE_PARTNER)
			@session.stringToSearch = ''
			@session.currentSucursal = ko.mapping.fromJS(DefaultModels.SUCURSAL)
			@session.currentDeparmentID = 1
			@session.currentSubcategorID = 1
			@session.categories([])
			@session.sucursals([])
			@session.signedUp(false)
			@session.currentOrder.numberProducts('0 items')
			@session.currentOrder.products([])
			@session.currentOrder.price(0.0)
			console.log 'session price'
			console.log @session.currentOrder.price()
			@session.currentOrder.sucursalId = 1

	setUserInfo: =>
		if !!Config.getItem('userObject')
			tempUser = JSON.parse(Config.getItem('userObject'))
			@user.id = tempUser.id
			@user.provider = tempUser.provider
			@user.email(tempUser.email)
			@user.discount(tempUser.discount)
			@user.name(tempUser.name)
			@user.discount(tempUser.discount)
			@user.firstName(tempUser.name.split(' ')[0])
			@user.lastName(tempUser.lastName or tempUser.last_name)
			@user.fullName(@user.firstName()+' '+@user.lastName())
			@user.phone(tempUser.phoneNumber or tempUser.phone_number)
			@user.profilePicture(tempUser.image or '../images/male_avatar.png')
			@shouldShowDiscountMessage(tempUser.discount > 0)
			@isLogged(true)
		else
			@user.firstName('amigo')
			@isLogged(false)
			@shouldShowDiscountMessage(false)

	signUp: =>
		$form = $('#sign-up .ui.form')
		$form.removeClass('error')
		if $form.form('is valid')
			data =
				name: $form.form('get value', 'firstName')
				address: $form.form('get value', 'address')
				last_name: $form.form('get value', 'lastName')
				email: $form.form('get value', 'email')
				phone_number: $form.form('get value', 'phoneNumber')
				password: $form.form('get value', 'password')
				password_confirmation: $form.form('get value', 'password')

			$('#sign-up .form .green.button').addClass('loading')
			RESTfulService.makeRequest('POST', '/users', data, (error, success, headers) =>
					if error
						$('#sign-up .form .green.button').removeClass('loading')
						$form.addClass('error')
						console.log error
						if error.responseJSON
							# REVIEW: It doesn't semd an array with the error texts
							@errorTextSignUp('No se pudo crear la cuenta')

						else
							@errorTextSignUp('No se pudo establecer conexión')
					else
						console.log success
						Config.setItem('userObject', JSON.stringify(success))
						Config.setItem('headers', JSON.stringify(headers))
						@setUserInfo()
						@session.signedUp(true)
						$('#shopping-cart .checkout').removeClass('hide')
						$('#shopping-cart .sign-up-banner').removeClass('show')
						# @setExistingSession()
						$('#sign-up').modal('hide')
						$('#shopping-cart').sidebar('hide')
				)

	resetPassword: ->
		$form = $('.reset-password .form')
		$form.removeClass('error')
		if $form.form('is valid')
			data =
				email: $form.form('get value', 'email')
				redirect_url: '/'

			$('.reset-password .green.button').addClass('loading')
			RESTfulService.makeRequest('POST', "/auth/password", data, (error, success, headers) =>
				$('.reset-password .green.button').removeClass('loading')
				if error
					$form.addClass('error')
					console.log 'An error has ocurred while reseting the password!'
					console.log error
					if error.responseJSON
						$form.form('add errors', error.responseJSON.errors)
					else
						$form.form('add errors', ['No se pudo establecer conexión'])
				else
					console.log success
					$('.reset-password .green.button').addClass('disabled')
					$('.reset-password .success.segment').transition('fade down')
					setTimeout((->
							$('.reset-password.modal').modal('hide')
						), 5000)
			)

	hideLoader: (product) ->
		$("##{product.id} .image img.loading").hide()
		$("##{product.id} .image .loader").hide()
		$("##{product.id} .image img.product").show()

	login: ->
		LoginService.regularLogin( (error, success) =>
				if error
					console.log 'An error ocurred while trying to login'
				else
					@setUserInfo()
					$('.login.modal').modal('hide')
					$('#mobile-menu').sidebar('hide')
					$('#shopping-cart').sidebar('hide')
			)

	loginFB: ->
		LoginService.FBLogin( (error, success) =>
				if error
					console.log 'An error ocurred while trying to login to FB'
				else
					$('#mobile-menu').sidebar('hide')
					@setUserInfo()
					$('#shopping-cart').sidebar('hide')
			)

	showProduct: (product) ->
		@selectedProduct = product
		@selectedProductCategory(product.subcategoryName)
		@selectedProductImage(product.image)
		@selectedProductName(product.name)
		@selectedProductSize(product.size)
		if product.description and product.description.startsWith('$') then @selectedProductDescription(product.desc) else @selectedProductDescription(product.description)
		@selectedProductPrice("$#{(product.frepi_price or product.frepiPrice).toLocaleString()}")
		$("#product-desc .ribbon.label").addClass('show') if @getProductByID(product.id)
		$('#product-desc').modal('show')

	setRulesValidation: ->
		$.fn.form.settings.rules.isValidQuantity = (value) ->
			value > 0

	setSizeSidebar: ->
		if $(window).width() < 480
			$('#shopping-cart').removeClass('wide')
		else
			$('#shopping-cart').addClass('wide')

		$(window).resize(->
			if $(window).width() < 480
				$('#shopping-cart').removeClass('wide')
			else
				$('#shopping-cart').addClass('wide')
		)

	setDOMElems: ->
		$('.ui.search')
			.search({
					minCharacters: 3
					error:
						noResults: 'No hay resultados para la búsqueda'
					apiSettings:
						url: 'http://ec2-54-68-79-250.us-west-2.compute.amazonaws.com:8080/api/v1/search/products?search={query}'
						# url: 'http://ec2-54-68-79-250.us-west-2.compute.amazonaws.com:3000/api/v1/search/products?search={query}'
						onResponse: (APIResponse) ->
							response = results: []

							$.each(APIResponse, ((index, item) ->
									maxResults = 5
									return false if index > maxResults

									response.results.push(
										id: item.id
										size: item.size
										name: item.name
										title: item.name
										desc: item.description
										description: "$#{(item.frepi_price).toLocaleString()}"
										image: item.image
										frepiPrice: item.frepi_price
									)
								))
							return response
				onSelect: (result, response) =>
					@showProduct(result)
					# return false
				})
		$('.ui.dropdown:not(#user-account)')
			.dropdown()
		$('#departments-menu .ui.dropdown')
			.dropdown()

		$('.ui.accordion')
			.accordion()
		$('#shopping-cart').sidebar({
				dimPage: false
				transition: 'overlay'
				onHide: ->
					$('#shopping-cart .checkout').removeClass('hide')
					$('#shopping-cart .sign-up-banner').removeClass('show')
			})
			.sidebar('attach events', '#store-secondary-navbar .right.menu button', 'show')
			.sidebar('attach events', '#shopping-cart i', 'show')
		$('#product-desc')
			.modal(
				onHidden: ->
					$('#product-desc form').form('clear')
					$('.modal .input.field').removeClass('show')
					$('.modal .dropdown.field').removeClass('hide')
					$("#product-desc .ribbon.label").removeClass('show')
			)
		$('.reset-password.modal').modal(
				onHidden: ->
					$('.reset-password .success.segment').attr('style', 'display: none !important')
					$('.reset-password .green.button').removeClass('disabled')
					$('.reset-password form').form('clear')
			)
			.modal('attach events', '.reset.trigger', 'show')
			.modal('attach events', '.reset-password .cancel.button', 'hide')
		$('.login.modal')
			.modal(
				onShow: ->
					$('#mobile-menu').sidebar('hide')
				onHide: ->
					$('.login.modal form').form('clear')
			)
			.modal('attach events', '.login.trigger', 'show')
			.modal('attach events', '.login.modal .cancel.button', 'hide')
		$('#sign-up')
			.modal(
				onShow: ->
					$('#shopping-cart').sidebar('hide')
					$('#mobile-menu').sidebar('hide')
				onHide: ->
					$('#sign-up.modal form').form('clear')
			)
			.modal('attach events', '.sign-up.trigger', 'show')
			.modal('attach events', '#sign-up.modal .cancel.button', 'hide')

		$('.reset-password .form').form(
				fields:
					email:
						identifier: 'email'
						rules: [
							{
								type: 'empty'
								prompt: 'Olvidaste poner el correo'
							}, {
								type: 'email'
								prompt: 'La dirección de correo no es válida'
							}
						]
				inline: true
				keyboardShortcuts: false
			)

		$('#product-desc form')
			.form(
				fields:
					quantity:
						identifier: 'quantity'
						rules: [
							{
								type: 'empty'
								prompt: 'Debes poner la cantidad'
							}
							{
								type: 'integer'
								prompt: 'Cantidad no válida'
							}
							{
								type: 'isValidQuantity[quantity]'
								prompt: 'Cantidad no válida'
							}
						]
					quantityDropdown:
						identifier: 'quantityDropdown'
						rules: [
							{
								type: 'empty'
								prompt: 'Debes poner la cantidad'
							}
						]
				inline: true
				keyboardShortcuts: false
			)

		$('.login.modal .form').form(
				fields:
					username:
						identifier: 'username'
						rules: [
							{
								type: 'empty'
								prompt: 'Olvidaste poner un usuario'
							}, {
								type: 'email'
								prompt: 'La dirección de correo no es válida'
							}
						]
					password:
						identifier: 'password'
						rules: [
							{
								type: 'empty'
								prompt: 'Olvidaste poner una contraseña'
							}, {
								type: 'length[6]'
								prompt: 'La contraseña debe tener por lo menos 6 caracteres'
							}
						]
				inline: true
				keyboardShortcuts: false
			)

		$('#sign-up .form').form(
				fields:
					firstName:
						identifier: 'firstName'
						rules: [
							{
								type: 'empty'
								prompt: 'Olvidaste poner tus nombres'
							}
						]
					lastName:
						identifier: 'lastName'
						rules: [
							{
								type: 'empty'
								prompt: 'Olvidaste poner tus apellidos'
							}
						]
					address:
						identifier: 'address'
						rules: [
							{
								type: 'empty'
								prompt: 'Olvidaste poner tu dirección'
							}
						]
					phoneNumber:
						identifier: 'phoneNumber'
						rules: [
							{
								type: 'empty'
								prompt: 'Olvidaste poner tu teléfono'
							}
						]
					email:
						identifier: 'email'
						rules: [
							{
								type: 'empty'
								prompt: 'Olvidaste poner tu e-mail'
							}, {
								type: 'email'
								prompt: 'Digitaste un e-mail no válido'
							}
						]
					password:
						identifier: 'password'
						rules: [
							{
								type: 'empty'
								prompt: 'Olvidaste poner una contraseña'
							}, {
								type: 'length[6]'
								prompt: 'La contraseña debe tener por lo menos 6 caracteres'
							}
						]
				inline: true
				keyboardShortcuts: false
			)
