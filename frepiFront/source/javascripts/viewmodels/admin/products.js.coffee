class ProductsVM extends AdminPageVM
	constructor: ->
		super()
		@AWSBucket = null
		@fileHasBeenUploaded = false
		@productsAlertText = ko.observable()
		@shouldShowProductsAlert = ko.observable(true)
		@currentProducts = ko.observableArray()
		@availableSucursals = ko.observableArray()
		@availableCategories = ko.observableArray()
		@availableSubcategories = ko.observableArray()
		@chosenProduct =
			id : ko.observable()
			image: ko.observable()
			name : ko.observable()
			sucursalID : ko.observable()
			frepiPrice : ko.observable()
			storePrice : ko.observable()
			subcategoryID : ko.observable()

		@productsPages =
			allPages: []
			lowerLimit: 0
			upperLimit: 0
			showablePages: ko.observableArray()

		# Methods to execute on instance
		# @setExistingSession()
		# @setUserInfo()
		@fetchProducts()
		@setDOMProperties()
		@setAWSCredentials()
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

		$('.create.modal form .green.button').addClass('loading')
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
		numShownPages = @productsPages.showablePages().length

		# Select which item should be set as active in the pagination list
		module = page.num % 10
		moduleFive = module % 5

		if module is 0 or moduleFive is 0
			activePage = 5
		else
			if moduleFive is 1 and page.num isnt 1
				activePage = 6
			else
				activePage = moduleFive

		midPoint = parseInt((@productsPages.lowerLimit + @productsPages.upperLimit)/2)

		unless numShownPages < 10
			if page.num > midPoint
				@productsPages.lowerLimit = midPoint
				possibleUpperLimit = @productsPages.lowerLimit + 10
				if possibleUpperLimit < @productsPages.allPages.length
					@productsPages.upperLimit = possibleUpperLimit
				else
					@productsPages.upperLimit = @productsPages.allPages.length - 1

		if (page.num - 1) is @productsPages.lowerLimit and (page.num - 1) isnt 0
			@productsPages.upperLimit = if numShownPages < 10 then @productsPages.showablePages()[4].num else midPoint
			@productsPages.lowerLimit = @productsPages.upperLimit - 10

		# Set new available pages in the pagination list
		@productsPages.showablePages(@productsPages.allPages.slice(@productsPages.lowerLimit, @productsPages.upperLimit))
		# Set new active page
		$('table.products .pagination .pages .item').removeClass('active')
		$("table.products .pagination .pages .item:nth-of-type(#{activePage})").addClass('active')
		# Fetch products according number's page
		@fetchProducts(page.num)

	fetchProducts: (numPage = 1) ->
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
					if @productsPages.allPages.length is 0
						totalPages = headers.totalItems/10
						for i in [0..totalPages]
							@productsPages.allPages.push({num: i+1})

						@productsPages.lowerLimit = 0
						@productsPages.upperLimit = if totalPages < 10 then totalPages else 10
						@productsPages.showablePages(@productsPages.allPages.slice(@productsPages.lowerLimit, @productsPages.upperLimit))

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
		$currentForm = if $('.create.modal').modal('is active') then $('.create.modal form') else $('.update.modal form')
		categoryID = $currentForm.form('get value', 'categoryID')
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
		RESTfulService.makeRequest('GET', "/stores/1/sucursals", {page: 1, perPage: 25}, (error, success, headers) =>
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
		$('.ui.progress')
			.progress({
					percent: 0
				})

	previewImage: (data, event) ->
		console.log 'previewing'
		$('.ui.modal img')[0].src = URL.createObjectURL(event.target.files[0])

	setAWSCredentials: =>
		AWS.config.region = 'us-east-1'
		AWS.config.update({accessKeyId: 'AKIAJPKUUYXNQVWSKLHA', secretAccessKey: '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'})

		@AWSBucket = new AWS.S3({
				params: {
					Bucket: 'frepi'
				}
		})

	uploadImage: (file, name) =>
		if file
			objKey = 'products/' + name
			params =
				Key: objKey
				ContentType: file.type
				Body: file
				ACL: 'public-read'

			# $('.create.modal form .green.button').addClass('loading')
			@fileHasBeenUploaded = false
			$currentProgressBar = if $('.create.modal').modal('is active') then $('.create.modal .progress') else $('.update.modal .progress')

			@AWSBucket.upload(params).on('httpUploadProgress', (evt) ->
					AWSprogress = parseInt((evt.loaded * 100) / evt.total)
					console.log "Uploaded :: " + parseInt((evt.loaded * 100) / evt.total)+'%'
					$currentProgressBar.progress({percent: AWSprogress})
				).send((err, data) =>
						@fileHasBeenUploaded = true unless err
						alert("File uploaded successfully.")
					)
		else
			alert 'Nothing to upload'
			# $('.create.modal form')


	uploadProduct: =>
		$fileChooser = $('.create.modal .dimmer input')[0]
		$form = $('.create.modal form')
		fileToUpload = $fileChooser.files[0]

		@uploadImage(fileToUpload, $form.form('get value', 'name')) unless @fileHasBeenUploaded

		@createProduct() if @fileHasBeenUploaded and $form.form('is valid')

		# if fileToUpload and $form.form('is valid')
		# 	objKey = 'products/' + $form.form('get value', 'name')
		# 	params =
		# 		Key: objKey
		# 		ContentType: fileToUpload.type
		# 		Body: fileToUpload
		# 		ACL: 'public-read'

		# 	$('.create.modal form .green.button').addClass('loading')
		# 	@AWSBucket.putObject(params, (err, data) =>
		# 			if err
		# 				console.log 'Error while uploading image to S3'
		# 			else
		# 				console.log(data)
		# 				console.log 'Image uploaded'
		# 				@createProduct()
		# 	)
		# else
		# 	console.log 'Nothing to upload'

products = new ProductsVM
ko.applyBindings(products)
