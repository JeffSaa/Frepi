class window.NearbyOrdersVM
	constructor: ->
		@orders = ko.observableArray(currentSession.nearbyOrders)