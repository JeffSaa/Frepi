class window.ActiveOrdersVM
	constructor: ->
		@setOrdersAttributes(currentSession.activeOrders)
		@orders = ko.observable(currentSession.activeOrders)

	setOrdersAttributes: (orders) ->
		for order in orders
			for product in order.ordersProducts
				product.checked = false

	checkItem: (item) ->
		item.checked = true