;(function($, window, document, undefined) {
  var pluginName = "dtFilter",
    defaults = {};

  // The actual plugin constructor
  function Plugin(element, options) {
    this.element = element;
    this.options = $.extend({}, defaults, options);
    this._defaults = defaults;
    this._name = pluginName;

    this.init();
  }

  Plugin.prototype = {

    init: function() {
      this.bindEvents();
    },
    bindEvents: function() {
      var self = this;

      // Listen for clear event
      $.subscribe('/general/clear-filters/', function() {
        $(self.element).find('select').prop('selectedIndex', 0);
      });

      $(this.element).on('change', 'select', function(e) {
        var filter = $(e.target).attr('name');
        $.publish('/general/change/', filter);
        $.publish('/filter/' + filter + '/', {
          e: e,
          data: $(e.target).val()
        })
      })
    }
  };

  $.fn[pluginName] = function(options) {
    return this.each(function() {
      if (!$.data(this, "plugin_" + pluginName)) {
        $.data(this, "plugin_" + pluginName,
          new Plugin(this, options));
      }
    });
  };

})(jQuery, window, document);