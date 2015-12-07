class HomeVM
	constructor: ->
		@loading = ko.observable(true)
		@currentDate = ko.observable()
		@currentState = ko.observable('ordenes recibidas')
		@activeOrders = ko.observableArray()
		@receivedOrders = ko.observableArray()
		@inStoreShoppers = ko.observableArray()
		@deliveringShoppers = ko.observableArray()
		@selectedOrder = ko.mapping.fromJS(DefaultModels.ORDER)
		
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
		@fetchOrders('received')
		@setSectionVisiblity()
		@setDOMElements()


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
	
	parseDate: (date) -> 
		return moment(date, moment.ISO_8601).format('dddd, DD MMMM YYYY')

	parseTime: (date) -> 
		return moment(date, moment.ISO_8601).format('h:mm A')			

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

	fetchOrders: (state) =>
		@lastFetchedState = state
		@loading(true)
		
		RESTfulService.makeRequest('GET', "/orders/#{state}", '', (error, success, headers) =>			
			if error
				console.log error
			else
				console.log success				
				@activeOrders(success)
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken

				switch state
					when 'received'
						@currentState('ordenes recibidas')
						@receivedOrders(success)
						@fetchInStoreShoppers()
					when 'shopping'
						@currentState('ordenes siendo compradas')
						@fetchDeliveryShoppers()
					when 'delivering'
						@currentState('ordenes siendo llevadas')
					when 'dispatched'
						@currentState('ordenes despachadas')

			@loading(false)
		)

	logout: ->
		# RESTfulService.makeRequest('DELETE', "/auth_supervisor/sign_out", '', (error, success, headers) =>			
		# 	if error
		# 		console.log 'An error has ocurred'
		# 	else
		# 		Config.destroyLocalStorage()
		# 		window.location.href = '../../'
		# )
		# IMPORTANT: Review this, the request isn't logging me out or destroying the session
		Config.destroyLocalStorage()
		window.location.href = '../../'

	markAsAcquired: (product) =>
		product.acquired(!product.acquired())

	refresh: ->
		@loading(true)
		RESTfulService.makeRequest('GET', "/orders/#{@lastFetchedState}", '', (error, success, headers) =>
			if error
				console.log error
			else
				console.log success
				@activeOrders(success)
				@receivedOrders(success) if @lastFetchedState is 'received'
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
				onHidden: ->
					$("#shopping-order .content .ui.dropdown").dropdown('set text', 'Selecciona Shopper')
					$("#shopping-order .content .ui.dropdown").dropdown('restore defaults')
			})
		$('.ui.dropdown').dropdown()
		$('.ui.checkbox').checkbox()

home = new HomeVM
ko.applyBindings(home)