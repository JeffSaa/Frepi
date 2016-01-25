class ProductsVM extends AdminPageVM
	constructor: ->
		super()
		@productsAlertText = ko.observable()
		@shouldShowProductsAlert = ko.observable(true)
		@currentProducts = ko.observableArray()
		@availableSucursals = ko.observableArray()
		@availableCategories = ko.observableArray()
		@availableSubcategories = ko.observableArray()
		@productsPages = ko.observableArray()
		@chosenProduct =
			id : ko.observable()
			image: ko.observable()
			name : ko.observable()
			sucursalID : ko.observable()
			frepiPrice : ko.observable()
			storePrice : ko.observable()
			subcategoryID : ko.observable()

		# Methods to execute on instance
		# @setExistingSession()
		# @setUserInfo()

		@fetchProducts(1)
		@setDOMProperties()
		@setRulesValidation()

	createProduct: ->
		$form = $('.create.modal form')
		data =
			name: $form.form('get value', 'name')
			frepiPrice: $form.form('get value', 'frepiPrice')
			storePrice: $form.form('get value', 'storePrice')
			subcategoryId : $form.form('get value', 'subcategoryID')
			image: 'http://s3-sa-east-1.amazonaws.com/frepi/products/' + $form.form('get value', 'name')

		console.log data

		if $form.form('is valid')
			RESTfulService.makeRequest('POST', "/stores/1/sucursals/#{$form.form('get value', 'sucursalID')}/products", data, (error, success, headers) =>
					$('.create.modal form .green.button').removeClass('loading')
					if error
						console.log 'An error has ocurred in the authentication.'
						console.log error
					else
						console.log success
						Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
						@currentProducts.push(success)
						$('.create.modal').modal('hide')
				)

	updateProduct: =>

	deleteProduct: =>
		$('.delete.modal .green.button').addClass('loading')
		RESTfulService.makeRequest('DELETE', "/stores/1/sucursals/#{@chosenProduct.sucursalID()}/products/#{@chosenProduct.id()}", '', (error, success, headers) =>
			$('.delete.modal .green.button').removeClass('loading')
			if error
				console.log 'An error has ocurred while fetching the subcategories!'
			else
				console.log success
				@currentProducts.remove( (product) =>
						return product.id is @chosenProduct.id()
					)
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
				$('.delete.modal').modal('hide')				
		)

	showUpdate: (product) =>
		@chosenProduct.image(product.image)
		$('.update.modal form')
			.form('set values',
					name 					: product.name
					frepiPrice 		: product.frepiPrice
					storePrice 		: product.storePrice
					sucursalID 		: product.sucursal.id
				)
		$('.update.modal').modal('show')

	showDelete: (product) =>
		console.log product
		@chosenProduct.id(product.id)
		@chosenProduct.name(product.name)
		@chosenProduct.sucursalID(product.sucursal.id)
		$('.delete.modal').modal('show')

	fetchProductsPage: (page) =>
		$('table.products .pagination .pages .item').removeClass('active')
		$("table.products .pagination .pages .item:nth-of-type(#{page.num})").addClass('active')
		@fetchProducts(page.num)
	
	fetchProducts: (numPage) ->
		@isLoading(true)
		data =
			page : numPage

		RESTfulService.makeRequest('GET', "/administrator/products", data, (error, success, headers) =>
			@isLoading(false)
			if error
				console.log 'An error has ocurred while fetching the products!'
				@shouldShowProductsAlert(true)
				@productsAlertText('Hubo un problema buscando la información de los productos')
			else
				@shouldShowProductsAlert(false)
				console.log 'After fetching products'
				console.log success
				if success.length > 0
					@shouldShowProductsAlert(false)
					if @productsPages().length is 0
						pages = []
						for i in [0..headers.totalItems/10]
							obj =
								num: i+1

							pages.push(obj)
						@productsPages(pages)
						$("table.products .pagination .pages .item:first-of-type").addClass('active')
					@currentProducts(success)
				else
					@shouldShowProductsAlert(true)
					@productsAlertText('No hay productos')
				
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
		)

	fetchCategories: ->
		RESTfulService.makeRequest('GET', "/categories", '', (error, success, headers) =>
			if error
				console.log 'An error has ocurred while fetching the categories!'
			else
				console.log success
				@availableCategories(success)
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
		)

	fetchSubcategories: ->
		categoryID = $('.ui.modal form').form('get value', 'categoryID')
		$('.ui.modal .subcategory.dropdown').addClass('loading')
		RESTfulService.makeRequest('GET', "/categories/#{categoryID}/subcategories", '', (error, success, headers) =>
			$('.ui.modal .subcategory.dropdown').removeClass('loading')
			if error
				console.log 'An error has ocurred while fetching the subcategories!'
			else
				console.log success
				@availableSubcategories(success)
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
		)

	fetchSucursals: ->
		RESTfulService.makeRequest('GET', "/stores/1/sucursals", {page: 1}, (error, success, headers) =>
			if error
				console.log 'An error has ocurred while updating the user!'
			else
				console.log success
				@availableSucursals(success)
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
				@fetchCategories()
		)

	setRulesValidation: ->
		emptyRule =
			type: 'empty'
			prompt: 'No puede estar vacío'
		$('.create.modal form')
			.form({
					fields:
						name:
							identifier: 'name'
							rules: [emptyRule]
						sucursal:
							identifier: 'sucursal'
							rules: [emptyRule]
						categoryID:
							identifier: 'categoryID'
							rules: [emptyRule]
						subcategoryID:
							identifier: 'subcategoryID'
							rules: [emptyRule]
						storePrice:
							identifier: 'storePrice'
							rules: [emptyRule]
						frepiPrice:
							identifier: 'frepiPrice'
							rules: [emptyRule]
					inline: true
					keyboardShortcuts: false
				})

	setDOMProperties: ->
		$('.ui.modal')
			.modal(
					onShow: =>
						@fetchSucursals()
				)
			.modal('attach events', '.create.button', 'show')
		$('.modal .ui.image')
			.dimmer({
					on: 'hover'
				})
		$('.ui.modal .dropdown')
			.dropdown()

	previewImage: (data, event) ->
		console.log 'previewing'
		$('.ui.modal img')[0].src = URL.createObjectURL(event.target.files[0])

	uploadProduct: =>
		AWS.config.region = 'us-east-1'
		AWS.config.update({accessKeyId: 'AKIAJPKUUYXNQVWSKLHA', secretAccessKey: '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'})

		AWS.config.credentials.get((err) ->
				alert(err) if err
				console.log(AWS.config.credentials)
		)

		bucketName = 'frepi'
		bucket = new AWS.S3({
				params: {
					Bucket: bucketName
				}
		})
		
		$fileChooser = $('.create.modal .dimmer input')[0]
		fileToUpload = $fileChooser.files[0]

		$form = $('.create.modal form')

		if fileToUpload and $form.form('is valid')
			objKey = 'products/' + $form.form('get value', 'name')
			params =
				Key: objKey
				ContentType: fileToUpload.type
				Body: fileToUpload
				ACL: 'public-read'

			$('.create.modal form .green.button').addClass('loading')
			bucket.putObject(params, (err, data) => 
					if err
						console.log 'Error while uploading image to S3'
					else
						console.log(data)
						console.log 'Image uploaded'
						@createProduct()
			)
		else
			console.log 'Nothing to upload'

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

products = new ProductsVM
ko.applyBindings(products)