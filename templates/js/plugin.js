// Generated by CoffeeScript 1.3.3
(function() {

  (function(jQuery) {
    var $, methods, settings;
    $ = jQuery;
    settings = {
      variableName: true,
      message: "hello world!"
    };
    methods = {
      init: function(options) {
        return this.each(function() {
          var $this;
          $.extend(settings, options);
          $this = $(this);
          console.log("pluginName init");
          return methods.spitMessage(settings.message);
        });
      },
      spitMessage: function(msg) {
        return console.log("your message is: " + msg);
      }
    };
    return $.fn.pluginName = function(method) {
      if (methods[method]) {
        return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
      } else if (typeof method === 'object' || !method) {
        return methods.init.apply(this, arguments);
      } else {
        return $.error('Method ' + method + ' does not exist on jQuery.pluginName');
      }
    };
  })(jQuery);

}).call(this);
