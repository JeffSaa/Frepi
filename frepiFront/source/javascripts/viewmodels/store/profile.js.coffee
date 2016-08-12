class ProfileVM extends TransactionalPageVM
	RouteValidator.checkUser()
	moment.locale('es')

	constructor: ->
		# Observables
		super()
		@AWSBucket = null
		@errorLabelText = ko.observable()
		@currentOrders = ko.observableArray()
		@showEmptyMessage = ko.observable()
		@checkOrders = ko.computed( =>
				@showEmptyMessage(@currentOrders().length is 0)
			)

		# Models
		@chosenOrder =
			id: ko.observable()
			status: ko.observable("")
			creationDate: ko.observable()
			arrivalDate: ko.observable()
			address: ko.observable()
			totalPrice: ko.observable()
			products: ko.observableArray()

		# Methods to execute on instance
		@setUserInfo()
		@setExistingSession()
		@fetchOrders()
		# @setAWSCredentials()
		@setDOMElements()
		@shouldShowOrders()
		@setSizeSidebar()
		# @setSizeButtons()


	closeEditEmail: ->
		$('#edit-email').modal('hide')
		$('#edit-email form').form('clear')

	closeEditPassword: ->
		$('#edit-password').modal('hide')
		$('#edit-password form').form('clear')

	fetchOrders: ->
		console.log 'Fetching the orders...'
		RESTfulService.makeRequest('GET', "/users/#{@user.id}/orders", '', (error, success, headers) =>
			if error
				console.log 'An error has ocurred while fetching the orders!'
			else
				# Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
				@setDOMElems()
				@currentOrders(success)
		)

	profile: ->
		Config.setItem('showOrders', 'false')
		$('.secondary.menu .item').tab('change tab', 'account')

	orders: ->
		Config.setItem('showOrders', 'true')
		$('.secondary.menu .item').tab('change tab', 'history')

	parseOrderDate: (orders) ->
		for order in orders
			order.date = moment(order.date, moment.ISO_8601).format('YYYY-MM-DD HH:mm:ss')
			order.arrivalTime = moment(order.arrivalTime, moment.ISO_8601).format('HH:mm')
			order.expiryTime = moment(order.expiryTime, moment.ISO_8601).format('HH:mm')
			order.scheduledDate = moment(order.scheduledDate, moment.ISO_8601).format('YYYY-MM-DD')

		return orders

	shouldShowOrders: ->
		if Config.getItem('showOrders') is 'true'
			$('.secondary.menu .item').tab('change tab', 'history')

	setDOMElements: ->
		$('#edit-email form').form({
				fields:
					newEmail:
						identifier: 'new-email'
						rules: [
							{
								type: 'empty'
								prompt: 'No puede estar vacío'
							}, {
								type: 'email'
								prompt: 'Digite una dirección de correo válida'
							}
						]
					match:
						identifier: 'confirmation-new-email'
						rules: [
							{
								type: 'match[new-email]'
								prompt: 'Las direcciones de correo deben ser iguales'
							}, {
								type: 'empty'
								prompt: 'No puede estar vacío'
							}, {
								type: 'email'
								prompt: 'Digite una dirección de correo válida'
							}
						]

					password:
						identifier: 'password'
						rules: [
							{
								type: 'empty'
								prompt: 'No puede estar vacía'
							}
						]
				inline: true
				keyboardShortcuts: false
			})
		$('#edit-password form').form({
				fields:
					newPassword:
						identifier: 'new-password'
						rules: [
							{
								type: 'empty'
								prompt: 'No puede estar vacía'
							}, {
								type: 'length[6]'
								prompt: 'La contraseña debe tener por lo menos 6 caracteres'
							}
						]
					match:
						identifier: 'confirmation-new-password'
						rules: [
							{
								type: 'match[new-password]'
								prompt: 'Las contraseñas no coinciden'
							}, {
								type: 'empty'
								prompt: 'No puede estar vacía'
							}
						]
					currentPassword:
						identifier: 'current-password'
						rules: [
							{
								type: 'empty'
								prompt: 'No puede estar vacía'
							}
						]
				inline: true
				keyboardShortcuts: false
			})
		$('#edit-user-info form').form({
				fields:
					firstName:
						identifier: 'firstName'
						rules: [
							{
								type: 'empty'
								prompt: 'No puede estar vacío'
							}
						]
					lastName:
						identifier: 'lastName'
						rules: [
							{
								type: 'empty'
								prompt: 'No puede estar vacío'
							}
						]
				inline: true
				keyboardShortcuts: false
			})
		$('#edit-email').modal(
				onHidden: ->
					$('#edit-email form').form('clear')
			).modal('attach events', '#edit-email .cancel.button', 'hide')

		$('#edit-password').modal(
				onHidden: ->
					$('#edit-password form').form('clear')
			).modal('attach events', '#edit-password .cancel.button', 'hide')

		$('#edit-user-info').modal(
				onHidden: ->
					$('#edit-user-info form').form('clear')
			).modal('attach events', '#edit-user-info .cancel.button', 'hide')

		$('.secondary.menu .item').tab(
				{cache: false}
			)
		$('#departments-menu').sidebar({
				transition: 'overlay'
				mobileTransition: 'overlay'
			}).sidebar('attach events', '#store-secondary-navbar button.basic', 'show')

		$('#mobile-menu')
			.sidebar('setting', 'transition', 'overlay')
			.sidebar('setting', 'mobileTransition', 'overlay')
			.sidebar('attach events', '#store-primary-navbar #store-frepi-logo .sidebar', 'show')
		$('.circular.image .ui.dimmer')
			.dimmer(
				on: 'hover'
			)

	showDepartments: ->
		$('#departments-menu').sidebar('toggle')

	showEditEmail: ->
		$('#edit-email').modal('show')

	showEditPassword: ->
		$('#edit-password').modal('show')

	showEditUser: ->
		$('#edit-user-info').modal('show')
		$('#edit-user-info form')
			.form('set values',
					firstName 	: @user.name()
					lastName 		: @user.lastName()
					phone 			: @user.phone()
				)

	# showShoppingCart: ->
	# 	$('#shopping-cart').sidebar('show')

	rebuyOrder: ->
		for productOrder in @chosenOrder.products()
			product = @getProductByID(productOrder.product.id)
			if !product
				@session.currentOrder.products.push(
					comment: productOrder.comment
					frepiPrice: productOrder.product.frepiPrice
					id: productOrder.product.id
					image: productOrder.product.image
					name: productOrder.product.name
					size: productOrder.product.size
					quantity: productOrder.quantity
					subcategoryId: productOrder.product.subcategory.id
					totalPrice: parseInt(productOrder.product.frepiPrice) * productOrder.quantity
				)
				$("##{productOrder.product.id} .image .label .quantity").text(productOrder.quantity)
				$("##{productOrder.product.id} .image .label").addClass('show')
			else
				oldProduct = product
				newProduct =
					comment: oldProduct.comment
					frepiPrice: oldProduct.frepiPrice or oldProduct.frepi_price
					id: oldProduct.id
					image: oldProduct.image
					name: oldProduct.name
					size: oldProduct.size
					quantity: oldProduct.quantity + productOrder.quantity
					subcategoryId: oldProduct.subcategoryId
					totalPrice: parseInt(((oldProduct.frepiPrice or oldProduct.frepi_price)*(oldProduct.quantity + productOrder.quantity)))

				@session.currentOrder.products.replace(oldProduct, newProduct)
				$("##{productOrder.product.id} .image .label .quantity").text(oldProduct.quantity + productOrder.quantity)

		@session.currentOrder.price(parseInt((@session.currentOrder.price() + @chosenOrder.totalPrice())))

		if @session.currentOrder.products().length isnt 1
			@session.currentOrder.numberProducts("#{@session.currentOrder.products().length} items")
		else
			@session.currentOrder.numberProducts("1 item")

		@saveOrder()
		$('#order-details').modal('hide')

	cancelOrder: ->
		$('#order-details .red.button').addClass('loading')
		RESTfulService.makeRequest('DELETE', "/users/#{@user.id}/orders/#{@chosenOrder.id()}", '', (error, success, headers) =>
			$('#order-details .red.button').removeClass('loading')
			if error
				console.log 'An error has ocurred while cancelling the orders!'
			else
				@currentOrders.remove( (order) =>
						return order.id is @chosenOrder.id()
					)
				$('#order-details').modal('hide')
		)

	setStatus: (status, truncated) ->
		switch status
			when 'DELIVERING'
				if not truncated then 'En camino' else 'E'
			when 'DISPATCHED'
				if not truncated then 'Entregada' else 'E'
			when 'RECEIVED'
				if not truncated then 'Recibida' else 'R'
			when 'SHOPPING'
				if not truncated then 'Comprando' else 'C'

	updateUser: (attributeToUpdate) ->
		data = {}

		switch attributeToUpdate
			when 'email'
				if $('#edit-email form').form('is valid')
					newEmail = $('#edit-email form').form('get value', 'new-email')
					data =
						email: newEmail

					$('#edit-email .green.button').addClass('loading')
					RESTfulService.makeRequest('PUT', "/users/#{@user.id}", data, (error, success, headers) =>
						$('#edit-email .green.button').removeClass('loading')
						if error
							console.log 'An error has ocurred while updating the user!'
						else
							console.log 'User has been updated'
							Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
							Config.setItem('userObject', JSON.stringify(success))
							@setUserInfo()
							$('#edit-email').modal('hide')
					)

			when 'password'
				if $('#edit-password form').form('is valid')
					newPassword = $('#edit-password form').form('get value', 'new-password')
					data =
						password: newPassword

					$('#edit-password .green.button').addClass('loading')
					RESTfulService.makeRequest('PUT', "/users/#{@user.id}", data, (error, success, headers) =>
						$('#edit-password .green.button').removeClass('loading')
						if error
							console.log 'An error has ocurred while updating the user!'
						else
							console.log 'User has been updated'
							Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
							Config.setItem('userObject', JSON.stringify(success))
							@setUserInfo()

							$('#edit-password').modal('hide')
					)

			when 'user'
				if $('#edit-user-info form').form('is valid')
					console.log 'Editing user info'
					newFirstName = $('#edit-user-info form').form('get value', 'firstName')
					newLastName = $('#edit-user-info form').form('get value', 'lastName')
					newPhone = $('#edit-user-info form').form('get value', 'phone')

					data =
						name: newFirstName
						last_name: newLastName
						phone_number: newPhone

					$('#edit-user-info .green.button').addClass('loading')
					RESTfulService.makeRequest('PUT', "/users/#{@user.id}", data, (error, success, headers) =>
						$('#edit-user-info .green.button').removeClass('loading')
						if error
							console.log 'An error has ocurred while updating the user!'
						else
							console.log 'User has been updated'
							Config.setItem('userObject', JSON.stringify(success))
							Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
							@setUserInfo()
							$('#edit-user-info').modal('hide')
					)

	setSizeButtons: ->
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

	generateUniqueID: ->
		idstr = String.fromCharCode(Math.floor((Math.random()*25)+65))
		loop
			asciiCode = Math.floor((Math.random()*42)+48) # ASCII code between numbers and letters
			idstr += String.fromCharCode(asciiCode) if asciiCode < 58 or asciiCode > 64
			break unless idstr.length < 32

		return idstr

	previewImage: (data, event) =>
		@user.profilePicture(URL.createObjectURL(event.target.files[0]))
		$('.circular.image img')[0].src = URL.createObjectURL(event.target.files[0])

	setAWSCredentials: =>
		AWS.config.region = 'us-east-1'
		AWS.config.update({accessKeyId: 'AKIAJPKUUYXNQVWSKLHA', secretAccessKey: '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'})

		@AWSBucket = new AWS.S3({
				params: {
					Bucket: 'frepi'
				}
		})

	uploadImage: =>
		$fileChooser = $('.circular.image .dimmer input')[0]
		fileToUpload = $fileChooser.files[0]

		@currentUniqueID = @generateUniqueID()
		if fileToUpload
			objKey = 'profile/' + @currentUniqueID
			params =
				Key: objKey
				ContentType: fileToUpload.type
				Body: fileToUpload
				ACL: 'public-read'

			$('.circular.image .dimmer .button').addClass('loading')

			@AWSBucket.upload(params).on('httpUploadProgress', (evt) ->
					AWSprogress = parseInt((evt.loaded * 100) / evt.total)
					console.log "Uploaded :: " + parseInt((evt.loaded * 100) / evt.total)+'%'
					$currentProgressBar.progress({percent: AWSprogress})
				).send((err, data) =>
						unless err
							@fileHasBeenUploaded = true
							if isCreationModalActive
								@createProduct()
							else
								@updateProduct()
						else
							$('.circular.image .dimmer .button').removeClass('loading')
					)
		else
			alert 'Nothing to upload'
			# $('.create.modal form')

	dateFormatter: (datetime)->
		return moment(datetime, moment.ISO_8601).format('DD MMMM YYYY [, ] h:mm A')

	parseDate: (date) ->
		return moment(date, moment.ISO_8601).format('DD MMMM YYYY')

	parseTime: (date) ->
		return moment(date, moment.ISO_8601).utcOffset("00:00").format('h:mm A')

	ProductsFormatter: (products) ->
		information = ''
		for product in products
			information += "#{product.product.name} x #{product.quantity}"
			if products.indexOf(product) isnt products.length - 1
				information += ", "

		return information

	productsText: (products) ->
		numberProducts = products.length
		if numberProducts is 1
			return "#{numberProducts} producto"
		else
			return "#{numberProducts} productos"

	showOrderDetails: (order) =>
		@chosenOrder.id(order.id)
		@chosenOrder.status(order.status)
		@chosenOrder.creationDate(@dateFormatter(order.date))
		@chosenOrder.arrivalDate("#{@parseDate(order.scheduledDate)}, #{@parseTime(order.arrivalTime)}")
		@chosenOrder.address(order.address)
		@chosenOrder.products(order.products)
		@chosenOrder.totalPrice(order.totalPrice)
		$('#order-details').modal('show')

profile = new ProfileVM
ko.applyBindings(profile)
