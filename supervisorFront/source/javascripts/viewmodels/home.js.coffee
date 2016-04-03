class HomeVM
	constructor: ->
		@loading = ko.observable(true)
		@shouldShowAsterisk = ko.observable(false)
		@shouldDisplayNoResultAlert = ko.observable(false)
		@receivedOrdersCount = ko.observable()
		@currentDate = ko.observable()
		@currentState = ko.observable('ordenes recibidas')
		@activeOrders = ko.observableArray()
		@receivedOrders = ko.observableArray()
		@inStoreShoppers = ko.observableArray()
		@deliveringShoppers = ko.observableArray()
		@selectedOrder = ko.mapping.fromJS(DefaultModels.ORDER)
		@pagination =
			allPages: []
			activePage: 0
			lowerLimit: 0
			upperLimit: 0
			showablePages: ko.observableArray()

		@deliveryShopperFullName = ko.computed( =>
				length = @selectedOrder.shopper().length
				if length > 0
					return @selectedOrder.shopper()[length - 1].firstName()+' '+@selectedOrder.shopper()[length - 1].lastName()
				else
					return null
			)

		@inStoreShopperFullName = ko.computed( =>
				length = @selectedOrder.shopper().length
				if length > 0
					return @selectedOrder.shopper()[0].firstName()+' '+@selectedOrder.shopper()[0].lastName()
				else
					return null
			)
		@lastFetchedState = null

		moment.locale('es')
		@fetchOrders('received', 1)
		@setSectionVisiblity()
		@setDOMElements()
		@automaticRefresher = setInterval(=>
				@refresh() if not(true in $('.ui.modal').modal('is active'))
			, 300000)


	finishOrder: ->
		orderID = @selectedOrder.id()
		data = {
			status: 'DISPATCHED'
		}

		RESTfulService.makeRequest('PUT', "/orders/#{orderID}", data, (error, success, headers) =>
				if error
					console.log error
				else
					console.log success
					Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
					setTimeout( ->
							$('#delivering-order').modal('hide')
						, 100)
					@refresh()
			)

	undoOrder: (data, event) ->
		orderID = @selectedOrder.id()
		triggeredButton = event.currentTarget

		$(triggeredButton).addClass('loading')
		RESTfulService.makeRequest('DELETE', "/orders/#{orderID}", '', (error, success, headers) =>
				$(triggeredButton).removeClass('loading')
				if error
					console.log error
				else
					console.log success
					if @lastFetchedState is 'received'
						@receivedOrdersCount(parseInt(@receivedOrdersCount()) - 1)
					else
						@receivedOrdersCount(parseInt(@receivedOrdersCount()) + 1)
					$('.ui.modal').modal('hide')
					@refresh()
			)

	parseDate: (date) ->
		return moment(date, moment.ISO_8601).format('dddd, DD MMMM YYYY')

	parseTime: (date) ->
		return moment(date, moment.ISO_8601).utcOffset("00:00").format('h:mm A')

	pickOrder: (order) =>
		console.log order
		ko.mapping.fromJS(order, @selectedOrder)
		switch @lastFetchedState
			when 'received'
				$('#assign-shopper').modal('show')
			when 'shopping'
				$('#shopping-order').modal('show')
			when 'delivering'
				$('#delivering-order').modal('show')
			when 'dispatched'
				$('#dispatched-order').modal('show')
			when 'disabled'
				$('#disabled-order').modal('show')

	setShopperToOrder: ->
		modal = ''
		if @lastFetchedState is 'shopping'
			modal = '#shopping-order'
		else
			modal = '#assign-shopper'

		$("#{modal} .actions .button:last-child").addClass('loading')
		$("#{modal} .dropdown").removeClass('error')
		shopperID = parseInt($("#{modal} .dropdown").dropdown('get value')[0])
		orderID = @selectedOrder.id()
		if !!shopperID
			data =
				shopperId : shopperID
				orderId 	: orderID

			RESTfulService.makeRequest('POST', '/orders', data, (error, success, headers) =>
				if error
					console.log error
				else
					console.log success
					Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
					@receivedOrdersCount(parseInt(@receivedOrdersCount()) - 1) unless @lastFetchedState is 'shopping'
					$("#{modal} .actions .button:last-child").removeClass('loading')
					setTimeout( ->
								$("#{modal}").modal('hide')
						, 100)
					@refresh()
			)
		else
			$("#{modal} .dropdown").addClass('error')
			$("#{modal} .actions .button:last-child").removeClass('loading')

	updateProductsOrder: =>
		$('#shopping-order .items + .button').addClass('loading')

		unacquiredProducts = []
		for product in @selectedOrder.products()
			unacquiredProducts.push({id: product.product.id(), acquired: product.acquired()})

		data =
			products 	: unacquiredProducts

		orderID = @selectedOrder.id()

		RESTfulService.makeRequest('PUT', "/orders/#{orderID}", data, (error, success, headers) =>
			if error
				console.log error
			else
				console.log success
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
				ko.mapping.fromJS(success, @selectedOrder)
				@shouldShowAsterisk(false)
				$('#shopping-order .items + .button').removeClass('loading')
		)

	printInvoice: ->
		@currentDate(moment().format('LLLL'))
		divToPrint = document.getElementById('pos-order')
		newWin = window.open("")
		newWin.document.write(divToPrint.outerHTML)
		head  = newWin.document.getElementsByTagName('head')[0]
		link  = document.createElement('link')
		link.rel  = 'stylesheet'
		link.type = 'text/css'
		link.href = '../../semantic/out/semantic.min.css'
		link.media = 'print'
		link2 = document.createElement('link')
		link2.rel  = 'stylesheet'
		link2.type = 'text/css'
		link2.href = '../../stylesheets/print.css'
		link2.media = 'print'
		head.appendChild(link)
		head.appendChild(link2)
		setTimeout( ->
				newWin.print()
				newWin.close()
			, 100)

	printList: ->
		@currentDate(moment().format('LLLL'))
		divToPrint = document.getElementById('pre-order')
		newWin = window.open("")
		newWin.document.write(divToPrint.outerHTML)
		head  = newWin.document.getElementsByTagName('head')[0]
		link  = document.createElement('link')
		link.rel  = 'stylesheet'
		link.type = 'text/css'
		link.href = '../../semantic/out/semantic.min.css'
		link.media = 'print'
		link2 = document.createElement('link')
		link2.rel  = 'stylesheet'
		link2.type = 'text/css'
		link2.href = '../../stylesheets/print.css'
		link2.media = 'print'
		head.appendChild(link)
		head.appendChild(link2)
		setTimeout( ->
				newWin.print()
				newWin.close()
			, 100)

	fetchInStoreShoppers: ->
		console.log 'IN STORE SHOPPERS'
		RESTfulService.makeRequest('GET', '/shoppers/in-store', '', (error, success, headers) =>
			if error
				console.log error
			else
				console.log success
				@inStoreShoppers(success)
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
		)

	fetchDeliveryShoppers: ->
		console.log 'DELIVERING SHOPPERS'
		RESTfulService.makeRequest('GET', '/shoppers/delivery', '', (error, success, headers) =>
			if error
				console.log error
			else
				console.log success
				@deliveringShoppers(success)
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
		)

	fetchPrevPage: ->
		if @pagination.activePage is 1
			nextPage = @pagination.allPages.length
		else
			nextPage = @pagination.activePage - 1

		@fetchPage(nextPage)

	fetchNextPage: ->
		if @pagination.activePage is @pagination.allPages.length
			nextPage = 1
		else
			nextPage = @pagination.activePage + 1

		@fetchPage(nextPage)

	fetchPage: (page) =>
		@pagination.activePage = page
		@fetchOrders(@lastFetchedState, @pagination.activePage)
		$('.pagination .pages .item').removeClass('active')
		$(".pagination .pages .item:nth-of-type(#{@pagination.activePage})").addClass('active')

	fetchOrders: (state, numPage, event) =>
		changed = not(state is @lastFetchedState)
		@shouldDisplayNoResultAlert(false)
		@lastFetchedState = state
		@loading(true)
		data =
			page : numPage

		RESTfulService.makeRequest('GET', "/orders/#{state}", data, (error, success, headers) =>
			if error
				console.log error
			else
				console.log success
				@activeOrders(success)
				if success.length > 0
					Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken

					totalPages = Math.ceil(headers.totalItems/10)

					if changed
						@pagination.activePage = 1
						@pagination.lowerLimit = 0
						@pagination.upperLimit = if totalPages < 10 then totalPages else 10
						@pagination.allPages.push(i) for i in [1..totalPages]
						@pagination.showablePages(@pagination.allPages.slice(@pagination.lowerLimit, @pagination.upperLimit))

						$(".pagination .pages .item:first-of-type").addClass('active')
				else
					@shouldDisplayNoResultAlert(true)

				if changed
					switch state
						when 'received'
							@currentState('ordenes recibidas')
							@receivedOrdersCount(headers.totalItems)
							@fetchInStoreShoppers()
						when 'shopping'
							@currentState('ordenes siendo compradas')
							@fetchDeliveryShoppers()
						when 'delivering'
							@currentState('ordenes siendo llevadas')
						when 'dispatched'
							@currentState('ordenes despachadas')
						when 'disabled'
							@currentState('ordenes deshabilitadas')

			@loading(false)
		)
		if event
			$('nav .container .item').removeClass('actived')
			$(event.currentTarget).addClass('actived')

	logout: ->
		RESTfulService.makeRequest('DELETE', "/auth_supervisor/sign_out", '', (error, success, headers) =>
			if error
				console.log 'An error has ocurred'
			else
				Config.destroyLocalStorage()
				window.location.href = '../../'
		)

	markAsAcquired: (product) =>
		@shouldShowAsterisk(true)
		product.acquired(!product.acquired())

	refresh: =>
		@loading(true)
		@shouldDisplayNoResultAlert(false)
		data =
			page : 1
		RESTfulService.makeRequest('GET', "/orders/#{@lastFetchedState}", data, (error, success, headers) =>
			if error
				console.log error
			else
				console.log success
				if success.length > 0
					@activeOrders(success)
					@receivedOrders(success) if @lastFetchedState is 'received'
				else
					@activeOrders([])
					@shouldDisplayNoResultAlert(true)
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
			@loading(false)
		)


	setSectionVisiblity: ->
		$nav = $('.orders.menu')
		$('#received-orders').visibility(
				onUpdate: (calculations) ->
					if calculations.topPassed
						$nav.addClass('nav-on-content')
					else
						$nav.removeClass('nav-on-content')
			)

	setDOMElements: ->
		$('#assign-shopper').modal({
				onHidden: ->
					$("#assign-shopper .content .ui.dropdown").dropdown('set text', 'Selecciona Shopper')
					$("#assign-shopper .content .ui.dropdown").dropdown('restore defaults')
			})
		$('#shopping-order').modal({
				onHidden: =>
					@shouldShowAsterisk(false)
					$("#shopping-order .content .ui.dropdown").dropdown('set text', 'Selecciona Shopper')
					$("#shopping-order .content .ui.dropdown").dropdown('restore defaults')
			})
		$('.ui.dropdown').dropdown()
		$('.ui.checkbox').checkbox()

home = new HomeVM
ko.applyBindings(home)
