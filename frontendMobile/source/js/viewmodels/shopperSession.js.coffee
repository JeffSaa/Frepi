class window.ShopperSessionVM
	constructor: (user) ->
		@user = user
		@activeOrders = ko.observableArray()
		@nearbyOrders = ko.observableArray()