class window.NearbyOrdersVM
	constructor: ->
		@orders = ko.observable(currentSession.nearbyOrders)