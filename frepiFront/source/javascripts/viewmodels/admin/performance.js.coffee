class PerformanceVM extends AdminPageVM
	constructor: ->
		super()
		@productsAlertText = ko.observable('Seleccione un rango de búsqueda')
		@shoppersAlertText = ko.observable('Seleccione un rango de búsqueda')
		@sucursalsAlertText = ko.observable('Seleccione un rango de búsqueda')
		@shouldShowShoppersAlert = ko.observable(true)
		@shouldShowProductsAlert = ko.observable(true)
		@shouldShowSucursalsAlert = ko.observable(true)
		@shoppersPages = ko.observableArray()
		@productsPages = ko.observableArray()
		@sucursalsPages = ko.observableArray()
		@currentProducts = ko.observableArray()
		@currentShoppers = ko.observableArray()
		@currentSucursals = ko.observableArray()

		# Methods to execute on instance

		@setDOMProperties()

	fetchEarningsPage: (page) =>
		$('article.sucursals .pagination .pages .item').removeClass('active')
		$("article.sucursals .pagination .pages .item:nth-of-type(#{page.num})").addClass('active')
		@fetchEarningsStatistics(page.startDate, page.endDate, page.num)

	fetchEarningsStatistics: (startDate, endDate, numPage) ->
		@isLoading(true)
		data =
			start_date : startDate
			end_date : endDate
			page : numPage

		RESTfulService.makeRequest('GET', '/administrator/statistics/earnings', data, (error, success, headers) =>
				@isLoading(false)
				if error
					console.log 'An error has ocurred while fetching earnings statistics'
					@productsAlertText('Ha ocurrido un error buscando la información')
				else
					console.log 'Earnings statistics fetching done'
					console.log success
					if success.length > 0
						@currentSucursals(success)
						@shouldShowSucursalsAlert(false)

						if @sucursalsPages().length is 0
							pages = []
							for i in [0..headers.totalItems/10]
								obj =
									num: i+1
									endDate : endDate
									startDate : startDate

								pages.push(obj)
							@sucursalsPages(pages)
						$("article.sucursals .pagination .pages .item:first-of-type").addClass('active')
					else
						@shouldShowSucursalsAlert(true)
						@sucursalsAlertText('No hubo ventas en el rango escogido')
					
					Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
			)

	fetchProductsPage: (page) =>
		$('article.products .pagination .pages .item').removeClass('active')
		$("article.products .pagination .pages .item:nth-of-type(#{page.num})").addClass('active')
		@fetchProductsStatistics(page.startDate, page.endDate, page.num)

	fetchProductsStatistics: (startDate, endDate, numPage) ->
		@isLoading(true)
		data =
			start_date : startDate
			end_date : endDate
			page : numPage

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
						
						if @productsPages().length is 0
							pages = []
							for i in [0..headers.totalItems/10]
								obj =
									num: i+1
									endDate : endDate
									startDate : startDate

								pages.push(obj)
							@productsPages(pages)
							$("article.products .pagination .pages .item:first-of-type").addClass('active')
					else
						@shouldShowProductsAlert(true)
						@productsAlertText('No hubo ventas en el rango escogido')
					
					Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
			)

	fetchShoppersPage: (page) =>
		$('article.shoppers .pagination .pages .item').removeClass('active')
		$("article.shoppers .pagination .pages .item:nth-of-type(#{page.num})").addClass('active')
		@fetchShoppersStatistics(page.startDate, page.endDate, page.num)

	fetchShoppersStatistics: (startDate, endDate, numPage) ->
		@isLoading(true)
		data =
			start_date : startDate
			end_date : endDate
			page : numPage

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

						if @shoppersPages().length is 0
							pages = []
							for i in [0..headers.totalItems/10]
								obj =
									num: i+1
									endDate : endDate
									startDate : startDate

								pages.push(obj)
							@shoppersPages(pages)
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