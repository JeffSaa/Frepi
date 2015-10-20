class window.MasterVM
	constructor: ->
		@target = ko.observable('login')

$(document).ready(->
	window.MasterVM = new MasterVM

	# ko.components.register('loading',
	# 		viewModel:
	# 			createViewModel: (params, componentInfo)->
	# 				return new LoadingVM
	# 		template:
	# 			require : 'text!../components/loading.html'
	# 	)

	ko.components.register('login',
			viewModel:
				createViewModel : (params, componentInfo) ->
					return new LoginVM
			template:
				require : 'text!../components/login.html'
		)

	ko.components.register('home',
			viewModel:
				createViewModel : (params, componentInfo) ->
					return new HomeVM
			template:
				require : 'text!../components/home.html'
		)

	ko.components.register('nearby',
			viewModel:
				createViewModel : (params, componentInfo) ->
					return new NearbyOrdersVM
			template:
				require : 'text!../components/nearbyOrders.html'
		)

	ko.components.register('active',
			viewModel:
				createViewModel : (params, componentInfo) ->
					return new ActiveOrdersVM
			template:
				require : 'text!../components/activeOrders.html'
		)

	# ko.components.register('calculate',
	# 		viewModel:
	# 			createViewModel : (params, componentInfo) ->
	# 				return new SingleSubjectVM
	# 		template:
	# 			require : 'text!../components/singlesubject.html'
	# 	)

	ko.applyBindings(MasterVM)
	router = new FrepiRouter()
	Backbone.history.start()
)