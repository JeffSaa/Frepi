class HomeVM
	constructor: ->
		@activeOrders = ko.observableArray()
		@nearbyOrders = ko.observableArray()

		@user = JSON.parse(Config.getItem('userObject'))

		@initGeolocation()
		@fetchActiveOrders()

	fetchActiveOrders: ->
		RESTfulService.makeRequest('GET', "/shoppers/#{@user.id}/orders", "", (error, success, headers)=>
				console.log 'Fetching shopper active orders...'
				if error
					console.log 'Orders couldnt be fetched'
				else
					console.log success
					if headers.accessToken
						Config.setItem('accessToken', headers.accessToken)
						Config.setItem('client', headers.client)
						Config.setItem('uid', headers.uid)
					@activeOrders(success)
					console.log @activeOrders()
					console.log 'FETCHING DONE'
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
					@nearbyOrders(success.orders)
					console.log 'FETCHING DONE'
			)

	getCurrentLocation: (position) =>
		console.log 'Getting current location...'
		currentLocation = {}
		currentLocation.latitude = position.coords.latitude
		currentLocation.longitude = position.coords.longitude
		@fetchNearbyOrders(currentLocation)

	initGeolocation: =>
		console.log 'Initializing geolocation...'
		if navigator.geolocation
			navigator.geolocation.getCurrentPosition(@getCurrentLocation)
		else
			alert("Browser doesn't support geolocation")


home = new HomeVM
ko.applyBindings(home)