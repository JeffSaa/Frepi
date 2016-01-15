class PerformanceVM extends AdminPageVM
	constructor: ->
		super()
		@alertText = ko.observable('Seleccione un rango de búsqueda')
		@shouldShowAlert = ko.observable(true)
		@currentProducts = ko.observableArray()
		@currentShoppers = ko.observableArray()
		@chosenOrder =
			id : ko.observable()
			totalPrice : ko.observable()
			products : ko.observableArray()

		# Methods to execute on instance
		
		# @setExistingSession()
		# @setorderInfo()
		# @fetchOrders()
		# @setRulesValidation()
		@setDOMProperties()

	showDelete: (order) =>
		@chosenOrder.id(order.id)
		$('.delete.modal').modal('show')

	showProducts: (order) =>
		@chosenOrder.products(order.products)
		@chosenOrder.totalPrice(order.totalPrice)
		$('.see.products.modal').modal('show')

	fetchProductsStatistics: (startDate, endDate) ->
		@isLoading(true)
		data =
			start_date : startDate
			end_date : endDate
			page : 1

		RESTfulService.makeRequest('GET', '/administrator/statistics/products', data, (error, success, headers) =>
				@isLoading(false)
				if error
					console.log 'An error has ocurred while fetching products statistics'
				else
					console.log 'Products statistics fetching done'
					console.log success
					if success.length > 0
						@currentProducts(success)
						@shouldShowAlert(false)
					else
						@shouldShowAlert(true)
						@alertText('No hubo ventas en el rango escogido')
					
					Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
			)

	getInStoreShopper: (shoppers) ->
		if shoppers.length > 0
			return shoppers[0].firstName + ' ' + shoppers[0].lastName
		else
			return '--'

	getDeliveryShopper: (shoppers) ->
		if shoppers.length > 1
			return shoppers[1].firstName + ' ' + shoppers[1].lastName
		else
			return '--'

	isOverdue: (data) ->
		scheduledDate = data.scheduledDate.split('T')[0]
		expiryTime = data.expiryTime.split('T')[1]
		newDateTime = scheduledDate + 'T' + expiryTime
		orderDate = moment(newDateTime, moment.ISO_8601)
		currentDate = moment()
		return currentDate.isAfter(orderDate) and data.status isnt 'DISPATCHED'

	parseDate: (date) -> 
		return moment(date, moment.ISO_8601).format('DD/MM/YYYY')

	parseTime: (date) -> 
		return moment(date, moment.ISO_8601).format('h:mm A')

	setRulesValidation: ->
		emptyRule =
			type: 'empty'
			prompt: 'No puede estar vacío'
		$('.create.modal form')
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
								emptyRule, {
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
		@isLoading(false)
		# $('.create.modal .dropdown')
		# 	.dropdown()
		$('#products-daterange')
			.daterangepicker(
					applyClass : 'positive'
					cancelClass : 'cancel'
				)
			.on('cancel.daterangepicker', (ev, picker) ->
					$('#products-daterange').val = ''
				)
			.on('apply.daterangepicker', (ev, picker) =>
					@fetchProductsStatistics(picker.startDate.format('YYYY-MM-DD'), picker.endDate.format('YYYY-MM-DD'))
				)


performance = new PerformanceVM
ko.applyBindings(performance)