class window.RouteValidator
	@checkUser: ->
		window.location.href = "../store/" unless Config.getItem('userObject')

	@checkCart: ->
		session = Config.getItem('currentSession')
		if session
			parsedSession = JSON.parse(session)
			if not parsedSession.currentOrder.products.length > 0 or parsedSession.currentOrder.price < 34000
				window.location.href = "store/"
		else
			window.location.href = "store/"
