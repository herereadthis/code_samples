// Generated by CoffeeScript 1.3.3
(function() {

  define(["jquery"], function($) {
    var em, exports, gVars, myFunction;
    exports = {};
    gVars = {};
    em = parseInt($("body").css("font-size"), 10);
    myFunction = function(vars) {
      console.log("passed variable: " + vars);
      console.log("set a global object literal gVars with init, " + gVars.myVar);
      return console.log("if I define something outside of functions,\nI can call on it,such as body's font-size: " + em + "em");
    };
    exports.init = function(element) {
      var settings;
      settings = {
        var1: "foo",
        var2: "bar"
      };
      gVars.myVar = "foobar";
      console.log("resize_fu init!");
      return myFunction(settings.var1);
    };
    return exports;
  });

}).call(this);
