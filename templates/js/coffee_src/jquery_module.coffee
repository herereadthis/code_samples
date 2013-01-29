# define ["jquery"], ( $ ) ->
define (require) ->
    # dependencies are like this
    # variables = require "MODULENAME"
    # where MODULENAME is defined by the data-main file found by require.js
    $ = require "jquery"
    exports = {}
    # global variables: Remember that whenever this module is used, it shares these global variables.
    # pass private objects if module is being used repeatedly, with each instance requiring separate parameters
    gVars = {}
    px = parseInt $("body").css("font-size"), 10

    # these functions stay within this module
    myFunction = ( vars ) ->
        console.log "passed variable: #{ vars }"
        console.log "set a global object literal gVars with init, #{ gVars.myVar }"
        console.log "if I define something outside of functions,\nI can call on it,such as body's font-size: #{ px }px"


    # example if another module requires a method out of this module. call myModule.myMethod(element)
    exports.myMethod = ( element ) ->
        console.log "some other module is using me!"


    exports.init = ( element ) ->
        settings = 
            var1: "foo"
            var2: "bar"
        gVars.myVar = "foobar"

        console.log "myFunction init!"

        myFunction settings.var1



    exports


