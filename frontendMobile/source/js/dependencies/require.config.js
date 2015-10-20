var require;

require = {
  baseUrl: "../../js",
  paths: {
		'knockout'				: 'dependencies/knockout',
		'jquery'					: 'jquery/jquery.min',
		'underscore'			: 'dependencies/underscore.min',
		'backbone'				: 'dependencies/backbone.min',
		'cryptojs'				: 'plugins/crypto-js',
		'router'					: 'classes/frepiMobileRouter',
		'encrypter'				: 'classes/encrypter',
		'config'					: 'classes/config',
		'RESTfulService'	: 'classes/RESTfulService',
		'login'						: 'viewmodels/login',
		'home'						: 'viewmodels/home'
  },
  shim: {
	"backbone": {
		  deps: ["jquery", "underscore"]
		},
	"knockout": {
		  exports: 'window.ko'
		}
  }
};