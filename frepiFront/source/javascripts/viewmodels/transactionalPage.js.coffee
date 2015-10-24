class window.TransactionalPageVM
	constructor: ->
		@session =
			categories: ko.observableArray()
			signUp: ko.observable()
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
			@session.signUp(true)

	# Returns null or a product if is currently in the cart
	getProductByName: (name) ->
		for product in @session.currentOrder.products()
			return product if product.name is name      
		
		return null

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
			$('.ui.modal').modal('hide')
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
			currentOrder:
				numberProducts: @session.currentOrder.numberProducts()
				products: @session.currentOrder.products()
				price: @session.currentOrder.price()
				sucursalId: @session.currentOrder.sucursalId

		Config.setItem('currentSession', JSON.stringify(session))

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

			console.log 'oldProduct'
			console.log oldProduct
			console.log 'newProduct'
			console.log newProduct

			console.log 'totalPrice product after removing an unit'
			console.log newProduct.totalPrice
			console.log '----------------------------------------'

			@session.currentOrder.products.replace(oldProduct, newProduct)
			
			@session.currentOrder.price(parseFloat((@session.currentOrder.price() - product.frepi_price).toFixed(2)))
			@saveOrder()
			console.log '--- After removing an unit from cart ---'
			console.log "PRICE: #{@session.currentOrder.price()}"
			console.log 'PRODUCTS:'
			console.log @session.currentOrder.products()
			console.log '----------------------------------------'

	removeItem: (item) ->
		@session.currentOrder.price(parseFloat((@session.currentOrder.price() - item.totalPrice).toFixed(2)))
		@session.currentOrder.products.remove(item)
		console.log '--- After removing an item from cart ---'
		console.log "PRICE: #{@session.currentOrder.price()}"
		console.log 'PRODUCTS:'
		console.log @session.currentOrder.products()
		console.log '----------------------------------------'
		@saveOrder()

		if @session.currentOrder.products().length isnt 1
			@session.currentOrder.numberProducts("#{@session.currentOrder.products().length} items")
		else
			@session.currentOrder.numberProducts("1 item")

	setExistingSession: ->
		session = Config.getItem('currentSession')

		if session
			session = JSON.parse(Config.getItem('currentSession'))
			@session.categories(session.categories)
			@session.signUp(session.signUp)
			@session.currentOrder.numberProducts(session.currentOrder.numberProducts)
			@session.currentOrder.products(session.currentOrder.products)
			@session.currentOrder.price(session.currentOrder.price)
			@session.currentOrder.sucursalId = session.currentOrder.sucursalId
		else
			@session.categories([])
			@session.signUp(false)
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