do polyLoad = ->

	# asyncScripts =
		# attrchange.js listens for modification of elements, using DOM4 Mutation observers
		# not needed for now.
		# git: https://github.com/meetselva/attrchange,
		# demo: http://meetselva.github.com/attrchange/
		# attrchange: '/static/stacks/js/library/attrchange.js'
		
		# these polyfillTests check to see if stuff is working. Check console logs
		# polyfillYep: '/static/stacks/js/polyfill_yep.js'
		# polyfillNope: '/static/stacks/js/polyfill_nope.js'

	# syncScripts = 
	# 	ajaxCalls: '/static/stacks/js/ajax_calls.js'

	# not running asyncScripts because we don't need any for now
	# for key, value of asyncScripts
	# 	$.ajax
	# 		url: value
	# 		dataType: "script"
	# 		async: true
	# 		success: (data) ->
				#callbacks

	# example to load scripts. 
	# for key, value of syncScripts
	# 	$.ajax
	# 		url: value
	# 		dataType: "script"
	# 		async: false
	# 		success: (data) ->
	# 			$(document).ready () ->
	# 				_this = $("body")
	# 				pageData =
	# 					objectType: _this.attr "data-object-type"
	# 					objectID: _this.attr "data-object-id"
	# 					userStatus: _this.attr "data-user-status"
	# 				if key is "ajaxCalls"
	# 					if pageData.userStatus is "staff" and pageData.objectType is "journal"
	# 						onLoadOptions =
	# 							id: pageData.objectID
	# 							hierarchy: pageData.objectType
	# 						_this.ajaxCalls
	# 							loadOptions: onLoadOptions
						

	# MutationObserver = window.MutationObserver or window.WebKitMutationObserver or window.MozMutationObserver	

	Modernizr.load [
		{
			# Test for Media queries
			# which is more or less, a test for IE8
			test : Modernizr.mq('only all'),
			yep : [
				# file_ballet.js will generate an overlay box on top of the page,
				# then populate with the file's content, depending on file type
				'/static/stacks/js/file_ballet.js'
			]
			nope : [
				# respond.js is a polyfill to grab media queries
				# git at https://github.com/scottjehl/Respond
				'/static/stacks/js/library/respond.min.js'
				# ie8.css + ie8Fix.js will lock in at 980 pixel fixed-width page, which simplifies page formatting
				'/static/stacks/ie8/ie8.css'
				'/static/stacks/ie8/ie8_fix.js'
				# ie8 version of file ballet
				'/static/stacks/ie8/file_ballet_ie8.js'
			]
			complete : () ->
				$ () ->
					_this = $("body")
					_this.fileBallet()

		},
		{
			# Test for DOM4 Mutation Observers
			# Posed the question to Stack Overflow, and I just answered it myself eventually.
			# http://stackoverflow.com/questions/13297380/
			test : MutationObserver = window.MutationObserver or window.WebKitMutationObserver or window.MozMutationObserver
			yep : [
				# flyout_Dancer.js is a mutation observer for the flyouts generated from the stack menu.
				# It positions and formats the flyouts in an ideal presentation to fit the browser window.
				'/static/stacks/js/flyout_dancer.js'
			]
			nope : [
				# flying_tango.js is a workaround for IE versions 8 and 9,
				# in order to handle the dancing mysteries of mutation observers - at least for flyouts
				'/static/stacks/ie8/diving_tango.js'
			]
		},
		{
			# Test for Multiple Backgrounds
			test : Modernizr.multiplebgs,
			yep : [
				'/static/stacks/js/auto_run.js'
				# FAQ loading script
				'/static/stacks/js/faq_disco.js'
			]
			nope : [
				# css PIE.js - we are not sure whether it is working.
				# revisit at post-launch
				'/static/stacks/js/library/PIE.js'
				'/static/stacks/js/pie_load.js'
				# FAQ loading script
				'/static/stacks/ie8/faq_disco_ie8.js'
			]
		},
		{
			# these files must be loaded regardless
			load: [
				# xml_render.css is a preset CSS file that handles Python XML rendering
				'/static/stacks/css/xml_render.css'
				# ajax_calls.js is the plugin for firing all of the API requests to make Stacks eJournals
				'/static/stacks/js/ajax_calls.js'
				# lazy loader plugin from http://www.appelsiini.net/projects/lazyload
				'/static/stacks/js/library/jquery.lazyload.min.js'
			]
			complete : () ->
				_this = $("body")
				pageData =
						objectType: _this.attr "data-object-type"
						objectID: _this.attr "data-object-id"
						userStatus: _this.attr "data-user-status"
				# methods.init in ajax_calls.js will do make its first Ajax call as
				# methods["" + hierarchy + "Ajax"] so it's a blind call
				# e.g. if hierarch is "journal" then the init will trigger methods["journal"+"Ajax"]
				# a.k.a methods.journalAjax
				if pageData.userStatus is "staff"
					onLoadOptions =
						id: pageData.objectID
						hierarchy: pageData.objectType
					_this.ajaxCalls
						loadOptions: onLoadOptions
		}
		# {
		# 	load: [
		# 		# pdfobject.js will embed a pdf into the page without requiring browser plugins!
		# 		# website: http://pdfobject.com/ and github: https://github.com/pipwerks/PDFObject
		# 		# '/static/stacks/js/library/pdfobject.js'
		# 		# jQuery Cookies will be implemented as part of DMS ticket 477, user preferences
		# 		#/static/stacks/js/library/jquery.cookie.js
		# 	],
		# 	complete : () ->
		# 		_this = $("body")
		# 		_this.fileBallet()
		# }
	]

