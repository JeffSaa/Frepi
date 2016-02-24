class window.TransactionalPageVM
	constructor: ->
		@session =
			currentStore				: null
			currentSucursal			: null
			currentDeparmentID	: null
			categories					: ko.observableArray()
			signedUp						: ko.observable()
			sucursals						: ko.observableArray()
			currentOrder:
				numberProducts	: ko.observable()
				products 				: ko.observableArray()
				price 					: ko.observable()
				sucursalId			: null
		@user =
			id 							: null
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

		@isLogged = ko.observable(false)

		@setUserInfo()
		@setDOMElems()

	checkout: =>
		if @user.id isnt null
			if @session.currentOrder.products().length > 0
				orderToPay =
					price: @session.currentOrder.price()
					products: @session.currentOrder.products()
					sucursalId: @session.currentOrder.sucursalId
				console.log orderToPay
				Config.setItem('orderToPay', JSON.stringify(orderToPay))
				window.location.href = '../../checkout.html'
			else
				console.log 'There is nothing in the cart...'
		else
			@session.signedUp(true)
			$('#shopping-cart .checkout').addClass('hide')
			$('#shopping-cart .sign-up-banner').addClass('show')

	# Returns null or a product if is currently in the cart
	getProductByName: (name) ->
		for product in @session.currentOrder.products()
			return product if product.name is name
		return null

	chooseStore: (store) ->
		ko.mapping.fromJS(store, @session.currentSucursal)
		$('#choose-store').modal('hide')

	chooseDeparment: (deparment) =>
		@session.currentDeparmentID = deparment.id
		@saveOrder()
		window.location.href = '../../store/deparment.html'

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
			totalPrice: parseFloat(product.frepiPrice)

		@session.currentOrder.products.replace(oldProduct, newProduct)
		@saveOrder()

		$noteLabel.css('display', 'inline-block')
		$textArea.css('display', 'none')
		$saveComment.css('display', 'none')

	addToCart: (productToAdd, quantitySelected) =>
		quantitySelected = parseInt($('#modal-dropdown').dropdown('get value')[0]) if quantitySelected is null
		product = @getProductByName(productToAdd.name)

		if not isNaN(quantitySelected)
			if !product
				# productToAdd.quantity = quantitySelected
				# productToAdd.totalPrice = parseFloat(productToAdd.frepiPrice)
				@session.currentOrder.products.push(
					comment: ""
					frepiPrice: productToAdd.frepiPrice
					id: productToAdd.id
					image: productToAdd.image
					name: productToAdd.name
					quantity: quantitySelected
					subcategoryId: productToAdd.subcategoryId
					totalPrice: parseFloat(productToAdd.frepiPrice)
				)
			else
				oldProduct = product
				newProduct =
					comment: oldProduct.comment
					frepiPrice: oldProduct.frepiPrice
					id: oldProduct.id
					image: oldProduct.image
					name: oldProduct.name
					quantity: oldProduct.quantity + quantitySelected
					subcategoryId: oldProduct.subcategoryId
					totalPrice: parseFloat((oldProduct.frepiPrice*(oldProduct.quantity+quantitySelected)).toFixed(2))

				@session.currentOrder.products.replace(oldProduct, newProduct)

			@session.currentOrder.price(parseFloat((@session.currentOrder.price() + productToAdd.frepiPrice*quantitySelected).toFixed(2)))
			console.log @session.currentOrder.price()
			$('#modal-dropdown').dropdown('set text', 'Cantidad')
			$('#modal-dropdown').dropdown('set value', '')
			$('#product-desc').modal('hide')

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
				window.location.href = '../../login.html'
		)

	saveOrder: ->
		session =
			categories: @session.categories()
			currentStore: ko.mapping.toJS(@session.currentStore)
			currentSucursal: ko.mapping.toJS(@session.currentSucursal)
			currentDeparmentID: @session.currentDeparmentID
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
		window.location.href = '../../store'

	removeFromCart: (product) ->
		if product.quantity is 1
			@removeItem(product)
		else
			oldProduct = product
			newProduct =
				comment: oldProduct.comment
				frepiPrice: oldProduct.frepiPrice
				id: oldProduct.id
				image: oldProduct.image
				name: oldProduct.name
				quantity: oldProduct.quantity - 1
				subcategoryId: oldProduct.subcategoryId
				totalPrice: parseFloat((oldProduct.frepiPrice*(oldProduct.quantity-1)).toFixed(2))

			@session.currentOrder.products.replace(oldProduct, newProduct)
			@session.currentOrder.price(parseFloat((@session.currentOrder.price() - product.frepiPrice).toFixed(2)))
			@saveOrder()

	removeItem: (item) ->
		@session.currentOrder.price(parseFloat((@session.currentOrder.price() - item.totalPrice).toFixed(2)))
		@session.currentOrder.products.remove(item)
		@saveOrder()

		if @session.currentOrder.products().length isnt 1
			@session.currentOrder.numberProducts("#{@session.currentOrder.products().length} items")
		else
			@session.currentOrder.numberProducts("1 item")

	setExistingSession: ->
		session = Config.getItem('currentSession')
		# console.log session.currentStore

		if session
			session = JSON.parse(Config.getItem('currentSession'))
			@session.currentStore = ko.mapping.fromJS(session.currentStore)
			@session.currentSucursal = ko.mapping.fromJS(session.currentSucursal)
			@session.currentDeparmentID = session.currentDeparmentID
			@session.categories(session.categories)
			@session.sucursals(session.sucursals)
			@session.signedUp(session.signedUp)
			@session.currentOrder.numberProducts(session.currentOrder.numberProducts)
			@session.currentOrder.products(session.currentOrder.products)
			@session.currentOrder.price(session.currentOrder.price)
			@session.currentOrder.sucursalId = session.currentOrder.sucursalId
		else
			@session.currentStore = ko.mapping.fromJS(DefaultModels.STORE_PARTNER)
			@session.currentSucursal = ko.mapping.fromJS(DefaultModels.SUCURSAL)
			@session.currentDeparmentID = 1
			@session.categories([])
			@session.sucursals([])
			@session.signedUp(false)
			@session.currentOrder.numberProducts('0 items')
			@session.currentOrder.products([])
			@session.currentOrder.price(0.0)
			@session.currentOrder.sucursalId = 1

	setUserInfo: =>
		if !!Config.getItem('userObject')
			tempUser = JSON.parse(Config.getItem('userObject'))
			@user.id = tempUser.id
			@user.email(tempUser.email)
			@user.name(tempUser.name)
			@user.firstName(tempUser.name.split(' ')[0])
			@user.lastName(tempUser.lastName or tempUser.last_name)
			@user.fullName(@user.firstName()+' '+@user.lastName())
			@user.phone(tempUser.phoneNumber or tempUser.phone_number)
			@user.profilePicture(tempUser.image or '../images/male_avatar.png')
			@isLogged(true)
		else
			@user.firstName('amigo')
			@isLogged(false)

	signUp: =>
		$form = $('#sign-up .ui.form')
		$form.removeClass('error')
		if $form.form('is valid')
			data =
				name: $form.form('get value', 'firstName')
				last_name: $form.form('get value', 'lastName')
				email: $form.form('get value', 'email')
				password: $form.form('get value', 'password')
				password_confirmation: $form.form('get value', 'password')

			$('#sign-up .form .green.button').addClass('loading')
			RESTfulService.makeRequest('POST', '/users', data, (error, success, headers) =>
					if error
						$('#sign-up .form .green.button').removeClass('loading')
						$form.addClass('error')
						console.log 'An error has ocurred in the authentication.'
						# @errorTextResponse(error.responseJSON.errors.toString())
					else
						console.log success
						Config.setItem('headers', JSON.stringify(headers))
						Config.setItem('credentials', JSON.stringify({email: data.email, password: data.password}))
						Config.setItem('userObject', JSON.stringify(success))
						@setUserInfo()
						@session.signedUp(true)
						$('#shopping-cart .checkout').removeClass('hide')
						$('#shopping-cart .sign-up-banner').removeClass('show')
						# @setExistingSession()
						$('#sign-up').modal('hide')
				)

	setDOMElems: ->
		# $('#choose-store')
		# 	.modal('setting', 'closable', false)
		# 	.modal('attach events', '#store-primary-navbar #target-store', 'show')
		$('.ui.search')
			.search({
					minCharacters: 3
					error:
						noResults: 'No hay resultados para la búsqueda'
					apiSettings:
						url: '//ec2-54-68-79-250.us-west-2.compute.amazonaws.com:8080/api/v1/search/products?search={query}'
						onResponse: (APIResponse) ->
							response = results: []

							$.each(APIResponse, ((index, item) ->
									maxResults = 5
									return false if index > maxResults

									response.results.push(
										id: item.id
										name: item.name
										title: item.name
										description: "$#{(item.frepi_price).toLocaleString()}"
										image: item.image
										frepiPrice: item.frepi_price
									)
								))
							return response
				onSelect: (result, response) ->
					console.log 'RESULT'
					console.log result
					console.log 'response'
					console.log response
					# return false
				})
		$('.ui.accordion')
			.accordion()
		$('#sign-up')
			.modal(
				onHide: ->
					$('#sign-up.modal form').form('clear')
			)
			.modal('attach events', '.sign-up-banner .green.button', 'show')
			.modal('attach events', '#sign-up.modal .cancel.button', 'hide')

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
