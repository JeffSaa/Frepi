class window.HomeVM
	constructor: ->
		@activeOrders = ko.observableArray()
		@nearbyOrders = ko.observableArray()
		@initGeolocation()
		@fetchActiveOrders()
		
	confirmOrder: ->
		console.log 'entra'
		$('#confirmation').openModal()

	fetchActiveOrders: ->
		RESTfulService.makeRequest('GET', "/shoppers/#{currentSession.user.id}/orders", "", (error, success, headers)=>
				console.log 'Fetching shopper active orders...'
				if error
					console.log 'Orders couldnt be fetched'
				else
					console.log success
					if headers.accessToken
						Config.setItem('headers', JSON.stringify(headers))
					currentSession.activeOrders = success
					@activeOrders(success)
					console.log @activeOrders()
					console.log 'ACTIVE ORDERS FETCHING DONE'
			)

	fetchNearbyOrders: (currentLocation) ->
		console.log currentLocation
		RESTfulService.makeRequest('GET', '/orders', currentLocation, (error, success, headers)=>
				console.log 'Fetching nearby orders by location...'
				if error
					console.log 'Nearby orders couldnt be fetched'
					console.log error
				else
					console.log success
					if headers.accessToken
						Config.setItem('headers', JSON.stringify(headers))
					currentSession.nearbyOrders = success
					@nearbyOrders(success)
					console.log 'NEARBY ORDERS FETCHING DONE'
			)

	getCurrentLocation: (position) =>
		console.log 'Getting current location...'
		currentLocation = {}
		currentLocation.latitude = position.coords.latitude
		currentLocation.longitude = position.coords.longitude
		currentSession.location = currentLocation
		@fetchNearbyOrders(currentLocation)

	initGeolocation: =>
		console.log 'Initializing geolocation...'
		if navigator.geolocation
			navigator.geolocation.getCurrentPosition(@getCurrentLocation)
		else
			alert("Browser doesn't support geolocation")
