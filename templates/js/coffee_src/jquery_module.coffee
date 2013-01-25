# define ["jquery"], ( $ ) ->
define (require) ->
	# dependencies are like this
	# variables = require "MODULENAME"
	# where MODULENAME is defined by the data-main file found by require.js
	$ = require "jquery"
	exports = {}
	gVars = {}
	px = parseInt $("body").css("font-size"), 10


	myFunction = ( vars ) ->
        console.log "passed variable: #{ vars }"
        console.log "set a global object literal gVars with init, #{ gVars.myVar }"
        console.log "if I define something outside of functions,\nI can call on it,such as body's font-size: #{ px }px"

	exports.init = ( element ) ->
		settings = 
			var1: "foo"
			var2: "bar"
		gVars.myVar = "foobar"

		console.log "myFunction init!"

		myFunction settings.var1



	exports


