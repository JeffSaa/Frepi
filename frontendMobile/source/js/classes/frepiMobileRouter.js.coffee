class window.FrepiRouter extends Backbone.Router
	routes:
		''				: 'loading'
		'login'		: 'login'
		'home'		: 'home'
		'nearby'	: 'nearby'
		'active'	:	'active'

	active: ->
		MasterVM.target('active')

	home: ->
		MasterVM.target('home')

	loading: ->
		MasterVM.target('login')

	login: ->
		MasterVM.target('login')

	nearby: ->
		MasterVM.target('nearby')		