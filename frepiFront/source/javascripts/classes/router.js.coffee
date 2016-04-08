class window.RouteValidator
	@checkUser: ->
		window.location.href = "../store/" unless Config.getItem('userObject')

	@checkCart: ->
		session = Config.getItem('currentSession')
		if session
			parsedSession = JSON.parse(session)
			window.location.href = "store/" unless parsedSession.currentOrder.products.length > 0
		else
			window.location.href = "store/"
