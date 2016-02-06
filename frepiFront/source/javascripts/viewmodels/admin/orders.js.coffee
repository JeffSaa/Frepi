class OrdersVM extends AdminPageVM
	constructor: ->
		super()
		@shouldShowError = ko.observable(false)
		@currentOrders = ko.observableArray()
		@chosenOrder =
			id : ko.observable()
			totalPrice : ko.observable()
			products : ko.observableArray()

		@ordersPages =
			allPages: []
			lowerLimit: 0
			upperLimit: 0
			showablePages: ko.observableArray()

		# Methods to execute on instance
		# @setExistingSession()
		# @setorderInfo()
		@fetchOrders()
		@setRulesValidation()
		@setDOMProperties()

	deleteOrder: =>
		$('.delete.modal .green.button').addClass('loading')
		RESTfulService.makeRequest('DELETE', "/orders/#{@chosenOrder.id()}", '', (error, success, headers) =>
			$('.delete.modal .green.button').removeClass('loading')
			if error
				console.log 'An error has ocurred while fetching the subcategories!'
			else
				console.log success
				@currentOrders.remove( (order) =>
							return order.id is @chosenOrder.id()
						)

				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
				$('.delete.modal').modal('hide')
		)

	showDelete: (order) =>
		@chosenOrder.id(order.id)
		$('.delete.modal').modal('show')

	showProducts: (order) =>
		@chosenOrder.products(order.products)
		@chosenOrder.totalPrice(order.totalPrice)
		$('.see.products.modal').modal('show')

	fetchOrdersPage: (page) =>
		@setPaginationItemsToShow(page.num, @ordersPages, 'table.orders')
		@fetchOrders(page.num)

	fetchOrders: (numPage = 1) ->
		@isLoading(true)
		data =
			page : numPage

		RESTfulService.makeRequest('GET', "/orders", data, (error, success, headers) =>
			@isLoading(false)
			if error
				console.log 'An error has ocurred while fetching the orders!'
			else
				console.log success
				if @ordersPages.allPages.length is 0
					totalPages = Math.ceil(headers.totalItems/10)
					for i in [0..totalPages]
						@ordersPages.allPages.push({num: i+1})

					@ordersPages.lowerLimit = 0
					@ordersPages.upperLimit = if totalPages < 10 then totalPages else 10
					@ordersPages.showablePages(@ordersPages.allPages.slice(@ordersPages.lowerLimit, @ordersPages.upperLimit))

					$("table.orders .pagination .pages .item:first-of-type").addClass('active')
				@currentOrders(success)
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
		$('.create.modal .dropdown')
			.dropdown()

orders = new OrdersVM
ko.applyBindings(orders)
