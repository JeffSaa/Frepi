class PerformanceVM extends AdminPageVM
	constructor: ->
		super()
		@productsAlertText = ko.observable('Seleccione un rango de búsqueda')
		@shoppersAlertText = ko.observable('Seleccione un rango de búsqueda')
		@sucursalsAlertText = ko.observable('Seleccione un rango de búsqueda')
		@shouldShowShoppersAlert = ko.observable(true)
		@shouldShowProductsAlert = ko.observable(true)
		@shouldShowSucursalsAlert = ko.observable(true)
		@currentProducts = ko.observableArray()
		@currentShoppers = ko.observableArray()
		@currentSucursals = ko.observableArray()

		@shoppersPages =
			allPages: []
			activePage: 0
			lowerLimit: 0
			upperLimit: 0
			showablePages: ko.observableArray()
		@productsPages =
			allPages: []
			activePage: 0
			lowerLimit: 0
			upperLimit: 0
			showablePages: ko.observableArray()
		@sucursalsPages =
			allPages: []
			activePage: 0
			lowerLimit: 0
			upperLimit: 0
			showablePages: ko.observableArray()

		# Methods to execute on instance

		@setDOMProperties()

	setPrevSucursalPage: ->
		if @sucursalsPages.activePage is 1
			nextPage = @sucursalsPages.allPages.length - 1
		else
			nextPage = @sucursalsPages.activePage - 1

		@fetchEarningsPage(@sucursalsPages.allPages[nextPage - 1])

	setNextSucursalPage: ->
		if @sucursalsPages.activePage is @sucursalsPages.allPages.length - 1
			nextPage = 1
		else
			nextPage = @sucursalsPages.activePage + 1

		@fetchEarningsPage(@sucursalsPages.allPages[nextPage - 1])

	fetchEarningsPage: (page) =>
		@sucursalsPages.activePage = page.num
		@setPaginationItemsToShow(@sucursalsPages, 'article.sucursals')
		@fetchEarningsStatistics(page.startDate, page.endDate, page.num)

	fetchEarningsStatistics: (startDate, endDate, numPage) ->
		@isLoading(true)
		data =
			start_date : startDate
			end_date : endDate
			page : numPage
			per_page : 30

		RESTfulService.makeRequest('GET', '/administrator/statistics/earnings', data, (error, success, headers) =>
				@isLoading(false)
				if error
					console.log 'An error has ocurred while fetching earnings statistics'
					@productsAlertText('Ha ocurrido un error buscando la información')
				else
					console.log 'Earnings statistics fetching done'
					console.log success
					if success.length > 0
						@shouldShowSucursalsAlert(false)
						@currentSucursals(success)

						if @sucursalsPages.allPages.length is 0
							totalPages = Math.ceil(headers.totalItems/30)
							for i in [0..totalPages]
								obj =
									num: i+1
									endDate : endDate
									startDate : startDate
								@sucursalsPages.allPages.push(obj)

							@sucursalsPages.activePage = 1
							@sucursalsPages.lowerLimit = 0
							@sucursalsPages.upperLimit = if totalPages < 10 then totalPages else 10
							@sucursalsPages.showablePages(@sucursalsPages.allPages.slice(@sucursalsPages.lowerLimit, @sucursalsPages.upperLimit))

							$("article.sucursals .pagination .pages .item:first-of-type").addClass('active')
					else
						@shouldShowSucursalsAlert(true)
						@sucursalsAlertText('No hubo ventas en el rango escogido')

					Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
			)

	setPrevProductPage: ->
		if @productsPages.activePage is 1
			nextPage = @productsPages.allPages.length - 1
		else
			nextPage = @productsPages.activePage - 1

		@fetchProductsPage(@productsPages.allPages[nextPage - 1])

	setNextProductPage: ->
		if @productsPages.activePage is @productsPages.allPages.length - 1
			nextPage = 1
		else
			nextPage = @productsPages.activePage + 1

		@fetchProductsPage(@productsPages.allPages[nextPage - 1])

	fetchProductsPage: (page) =>
		@productsPages.activePage = page.num
		@setPaginationItemsToShow(@productsPages, 'article.products')
		@fetchProductsStatistics(page.startDate, page.endDate, page.num)

	fetchProductsStatistics: (startDate, endDate, numPage) ->
		@isLoading(true)
		data =
			start_date : startDate
			end_date : endDate
			page : numPage
			per_page : 30

		RESTfulService.makeRequest('GET', '/administrator/statistics/products', data, (error, success, headers) =>
				@isLoading(false)
				if error
					console.log 'An error has ocurred while fetching products statistics'
					@productsAlertText('Ha ocurrido un error buscando la información')
				else
					console.log 'Products statistics fetching done'
					console.log success
					if success.length > 0
						@currentProducts(success)
						@shouldShowProductsAlert(false)

						if @productsPages.allPages.length is 0
							totalPages = Math.ceil(headers.totalItems/30)
							for i in [0..totalPages]
								obj =
									num: i+1
									endDate : endDate
									startDate : startDate
								@productsPages.allPages.push(obj)

							@productsPages.activePage = 1
							@productsPages.lowerLimit = 0
							@productsPages.upperLimit = if totalPages < 10 then totalPages else 10
							@productsPages.showablePages(@productsPages.allPages.slice(@productsPages.lowerLimit, @productsPages.upperLimit))

							$("article.products .pagination .pages .item:first-of-type").addClass('active')
					else
						@shouldShowProductsAlert(true)
						@productsAlertText('No hubo ventas en el rango escogido')

					Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
			)

	setPrevShopperPage: ->
		if @shoppersPages.activePage is 1
			nextPage = @shoppersPages.allPages.length - 1
		else
			nextPage = @shoppersPages.activePage - 1

		@fetchShoppersPage(@shoppersPages.allPages[nextPage - 1])

	setNextShopperPage: ->
		if @shoppersPages.activePage is @shoppersPages.allPages.length - 1
			nextPage = 1
		else
			nextPage = @shoppersPages.activePage + 1

		@fetchShoppersPage(@shoppersPages.allPages[nextPage - 1])

	fetchShoppersPage: (page) =>
		@shoppersPages.activePage = page.num
		@setPaginationItemsToShow(@shoppersPages, 'article.shoppers')
		@fetchShoppersStatistics(page.startDate, page.endDate, page.num)

	fetchShoppersStatistics: (startDate, endDate, numPage) ->
		@isLoading(true)
		data =
			start_date : startDate
			end_date : endDate
			page : numPage
			per_page : 30

		RESTfulService.makeRequest('GET', '/administrator/statistics/shoppers', data, (error, success, headers) =>
				@isLoading(false)
				if error
					console.log 'An error has ocurred while fetching shoppers statistics'
					@productsAlertText('Ha ocurrido un error buscando la información')
				else
					console.log 'Shoppers statistics fetching done'
					console.log success
					if success.length > 0
						@currentShoppers(success)
						@shouldShowShoppersAlert(false)

						if @shoppersPages.allPages.length is 0
							totalPages = Math.ceil(headers.totalItems/30)
							for i in [0..totalPages]
								obj =
									num: i+1
									endDate : endDate
									startDate : startDate
								@shoppersPages.allPages.push(obj)

							@shoppersPages.activePage = 1
							@shoppersPages.lowerLimit = 0
							@shoppersPages.upperLimit = if totalPages < 10 then totalPages else 10
							@shoppersPages.showablePages(@shoppersPages.allPages.slice(@shoppersPages.lowerLimit, @shoppersPages.upperLimit))

							$("article.shoppers .pagination .pages .item:first-of-type").addClass('active')
					else
						@shouldShowShoppersAlert(true)
						@shoppersAlertText('No hubo ventas en el rango escogido')

					Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
			)

	getProfit: (frepiPrice, storePrice) ->
		profit = frepiPrice - storePrice
		return Math.round(profit * 100) / 100

	setDOMProperties: ->
		@isLoading(false)
		$('#products-daterange')
			.daterangepicker(
					applyClass : 'positive'
					cancelClass : 'cancel'
				)
			.on('cancel.daterangepicker', (ev, picker) ->
					$('#products-daterange').val = ''
				)
			.on('apply.daterangepicker', (ev, picker) =>
					@fetchProductsStatistics(picker.startDate.format('YYYY-MM-DD'), picker.endDate.format('YYYY-MM-DD'), 1)
				)
		$('#shoppers-daterange')
			.daterangepicker(
					applyClass : 'positive'
					cancelClass : 'cancel'
				)
			.on('cancel.daterangepicker', (ev, picker) ->
					$('#shoppers-daterange').val = ''
				)
			.on('apply.daterangepicker', (ev, picker) =>
					@fetchShoppersStatistics(picker.startDate.format('YYYY-MM-DD'), picker.endDate.format('YYYY-MM-DD'), 1)
				)
		$('#sucursals-daterange')
			.daterangepicker(
					applyClass : 'positive'
					cancelClass : 'cancel'
				)
			.on('cancel.daterangepicker', (ev, picker) ->
					$('#sucursals-daterange').val = ''
				)
			.on('apply.daterangepicker', (ev, picker) =>
					@fetchEarningsStatistics(picker.startDate.format('YYYY-MM-DD'), picker.endDate.format('YYYY-MM-DD'), 1)
				)


performance = new PerformanceVM
ko.applyBindings(performance)
