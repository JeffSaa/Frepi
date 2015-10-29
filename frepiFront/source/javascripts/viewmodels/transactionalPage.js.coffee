class window.TransactionalPageVM
	constructor: ->
		@DEFAULT_STORE_PARTNER = 
			id: 2
			nit: "21-530-4163"
			name: "Feest-Kub"
			logo: "http://www.biz-logo.com/examples/002.gif"
			description: "Non voluptatem suscipit beatae."
			created_at: "2015-10-13T23:08:25.531Z"
			updated_at: "2015-10-13T23:08:25.531Z"
		@DEFAULT_SUCURSAL =
			address: "26172 Lucienne Corners"
			created_at: "2015-10-13T23:08:25.559Z"
			id: -1
			latitude: "-57.2628762651957"
			longitude: "-159.203929960594"
			manager_email: "bernardo_jaskolski@heaneystoltenberg.net"
			manager_full_name: "Dorian Bartell"
			manager_phone_number: "4477667382"
			name: "Langworth, Lubowitz and Hirthe"
			phone_number: "2283261"
			store_partner_id: 2
			updated_at: "2015-10-13T23:08:25.559Z"

		@session =
			currentStore			: null
			currentSucursal		: null
			categories				: ko.observableArray()
			signedUp					: ko.observable()
			sucursals					: ko.observableArray()
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
		@setDOMelems()

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

	# Returns null or a product if is currently in the cart
	getProductByName: (name) ->
		for product in @session.currentOrder.products()
			return product if product.name is name
		return null

	chooseStore: (store) =>
		ko.mapping.fromJS(store, @session.currentSucursal)
		$('#choose-store').modal('hide')

	addToCart: (productToAdd, quantitySelected) =>
		quantitySelected = parseInt($('#modal-dropdown').dropdown('get value')[0]) if quantitySelected is null
		product = @getProductByName(productToAdd.name)

		if not isNaN(quantitySelected)
			if !product
				productToAdd.quantity = quantitySelected
				productToAdd.totalPrice = parseFloat(productToAdd.frepi_price)
				@session.currentOrder.products.push(productToAdd)
			else
				oldProduct = product
				newProduct =
					available: oldProduct.available
					frepi_price: oldProduct.frepi_price
					id: oldProduct.id
					image: oldProduct.image
					name: oldProduct.name
					quantity: oldProduct.quantity + quantitySelected
					referenceCode: oldProduct.referenceCode
					salesCount: oldProduct.salesCount
					storePrice: oldProduct.storePrice
					subcategoryName: oldProduct.subcategoryName
					subcategoryId: oldProduct.subcategoryId
					totalPrice: parseFloat((oldProduct.frepi_price*(oldProduct.quantity+quantitySelected)).toFixed(2))

				@session.currentOrder.products.replace(oldProduct, newProduct)
			
			@session.currentOrder.price(parseFloat((@session.currentOrder.price() + productToAdd.frepi_price*quantitySelected).toFixed(2)))
			console.log @session.currentOrder.price()
			$('#modal-dropdown').dropdown('set text', 'Cantidad')
			$('#modal-dropdown').dropdown('set value', '')
			$('#product-desc').modal('hide')
			console.log @session.currentOrder.products()
			@saveOrder()

			if @session.currentOrder.products().length isnt 1
				@session.currentOrder.numberProducts("#{@session.currentOrder.products().length} items")
			else
				@session.currentOrder.numberProducts("1 item")

	logout: ->
		Config.destroyLocalStorage()
		window.location.href = '../../login.html'

	saveOrder: ->
		session =
			categories: @session.categories()
			currentStore: ko.mapping.toJS(@session.currentStore)
			currentSucursal: ko.mapping.toJS(@session.currentSucursal)
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
				available: oldProduct.available
				frepi_price: oldProduct.frepi_price
				id: oldProduct.id
				image: oldProduct.image
				name: oldProduct.name
				quantity: oldProduct.quantity - 1
				referenceCode: oldProduct.referenceCode
				salesCount: oldProduct.salesCount
				storePrice: oldProduct.storePrice
				subcategoryName: oldProduct.subcategoryName
				subcategoryId: oldProduct.subcategoryId
				totalPrice: parseFloat((oldProduct.frepi_price*(oldProduct.quantity-1)).toFixed(2))

			@session.currentOrder.products.replace(oldProduct, newProduct)
			@session.currentOrder.price(parseFloat((@session.currentOrder.price() - product.frepi_price).toFixed(2)))
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

		if session
			session = JSON.parse(Config.getItem('currentSession'))
			@session.currentStore = ko.mapping.fromJS(session.currentStore)
			@session.currentSucursal = ko.mapping.fromJS(session.currentSucursal)
			@session.categories(session.categories)
			@session.sucursals(session.sucursals)
			@session.signedUp(session.signedUp)
			@session.currentOrder.numberProducts(session.currentOrder.numberProducts)
			@session.currentOrder.products(session.currentOrder.products)
			@session.currentOrder.price(session.currentOrder.price)
			@session.currentOrder.sucursalId = session.currentOrder.sucursalId
		else
			@session.currentStore = ko.mapping.fromJS(@DEFAULT_STORE_PARTNER)
			@session.currentSucursal = ko.mapping.fromJS(@DEFAULT_SUCURSAL)
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
			@user.profilePicture(tempUser.image)
		else
			@user.firstName('amigo')

	signUp: ->

	setDOMelems: ->
		$('#choose-store')
			.modal('setting', 'closable', false)
			.modal('attach events', '#store-primary-navbar #target-store', 'show')
		$('#sign-up')
			.modal('attach events', '.sign-up-banner .green.button', 'show')
		$('#sign-up .form').form(
				fields: 
					firstName:
						identifier: 'firstName'
						rules: [
							{
								type: 'empty'
								prompt: 'Por favor digite un nombre'
							}
						]
					lastName:
						identifier: 'lastName'
						rules: [
							{
								type: 'empty'
								prompt: 'Por favor digite un usuario'
							}
						]
					email:
						identifier: 'email'
						rules: [
							{
								type: 'empty'
								prompt: 'Por favor digite un usuario'
							}, {
								type: 'email'
								prompt: 'Por favor digite un e-mail válido'
							}
						]
					password:
						identifier: 'password'
						rules: [
							{
								type: 'empty'
								prompt: 'Por favor digite una contraseña'
							}, {
								type: 'length[6]'
								prompt: 'La contraseña debe tener por lo menos 6 caracteres'
							}
						]
				inline: true
				keyboardShortcuts: false
			)