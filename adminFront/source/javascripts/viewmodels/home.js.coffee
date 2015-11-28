class HomeVM
	constructor: ->
		@loading = ko.observable(true)
		@currentDate = ko.observable()
		@activeOrders = ko.observableArray()
		@activeShoppers = ko.observableArray()
		@selectedOrder = ko.mapping.fromJS(DefaultModels.ORDER)
		@lastFetchedState = null
		
		@fetchShoppers()
		@fetchOrders('received')
		@setSectionVisiblity()
		@setDOMElements()

	pickOrder: (order) =>
		console.log order
		ko.mapping.fromJS(order, @selectedOrder)
		$('#assign-shopper').modal('show')

	pickShopperForShopping: ->
		$('#assign-shopper .actions .button:last-child').addClass('loading')
		$('#assign-shopper .dropdown').removeClass('error')
		shopperID = parseInt($('#assign-shopper .dropdown').dropdown('get value')[0])
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
					$('#assign-shopper .actions .button:last-child').removeClass('black basic loading')
					$('#assign-shopper .actions .button:last-child').addClass('green')
					$('#assign-shopper .actions .button:last-child').text('Hecho!')
					setTimeout( ->
							$('#assign-shopper').modal('hide')
						, 100)					
					@refresh()
			)
		else
			$('#assign-shopper .dropdown').addClass('error')

		$('#assign-shopper .actions .button:last-child').removeClass('loading')

	printList: ->
		@currentDate(moment().format('LLL'))
		divToPrint = document.getElementById('unassigned-shopper')
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

	fetchShoppers: ->
		console.log 'All shoppers'
		RESTfulService.makeRequest('GET', '/shoppers', '', (error, success, headers) =>
			if error
				console.log error
			else
				console.log success
				@activeShoppers(success)
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
			@loading(false)
		)

	logout: ->
		RESTfulService.makeRequest('DELETE', "/auth_supervisor/sign_out", '', (error, success, headers) =>			
			if error
				console.log 'An error has ocurred'
			else
				Config.destroyLocalStorage()
				window.location.href = '../../'
		)
		# IMPORTANT: Review this, the request isn't logging me out or destroying the session
		# Config.destroyLocalStorage()
		# window.location.href = '../../'

	refresh: ->
		@loading(true)
		RESTfulService.makeRequest('GET', "/orders/#{@lastFetchedState}", '', (error, success, headers) =>
			if error
				console.log error
			else
				console.log success
				@activeOrders(success)
				Config.setItem('headers', JSON.stringify(headers)) if headers.accessToken
			@loading(false)
		)


	setSectionVisiblity: ->
		$nav = $('.orders.menu')
		$('#received-orders').visibility(
				onUpdate: (calculations) ->
					console.log 'Calculations updated!!!!!'
					if calculations.topPassed
						console.log 'TOP PASSEDD!!!'
						$nav.addClass('nav-on-content')
					else
						$nav.removeClass('nav-on-content')
			)

	setDOMElements: ->
		$('#assign-shopper .dropdown').dropdown()

home = new HomeVM
ko.applyBindings(home)