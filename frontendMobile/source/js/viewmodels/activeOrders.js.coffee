class window.ActiveOrdersVM
	constructor: ->
		console.log 'Its here in active Orders'
		@setOrdersAttributes()
		@orders = ko.mapping.fromJS(currentSession.activeOrders)
		@test = ko.observable('MOTOROLA')

	setOrdersAttributes: ->
		console.log 'Setting order attributes'
		for order in currentSession.activeOrders
			order.checkedItems = 0
			for product in order.ordersProducts
				product.checked = false

	markAsChecked: (product, order) ->
		product.checked(!product.checked())
		if product.checked()
			order.checkedItems(order.checkedItems() + 1) 
		else
			order.checkedItems(order.checkedItems() - 1)