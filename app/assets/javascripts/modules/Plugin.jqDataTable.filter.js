;
(function($, window, document, undefined) {
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

    /**
     * Method called internally
     * @return {Object} Return `this` to maintain chaining (?)
     */
    init: function() {
      this.bindEvents();
      return this;
    },
    /**
     * Rest this control's selected index to 0
     */
    resetSelectIndex: function() {
      $(this.element).find('select').prop('selectedIndex', 0);
    },

    /**
     * Bind all the events
     */
    bindEvents: function() {
      var self = this;

      // Listen for clear event
      $.subscribe('/general/clear-filters/', function() {
        self.resetSelectIndex();
      });

      // Listen for scheme change and clear index
      $.subscribe('/scheme/change/', function() {
        self.resetSelectIndex();
      });

      // publish the events with filter specific data
      $(this.element).on('change', 'select', function(e) {
        var filter = $(e.target).attr('name');
        $.publish('/general/change/', filter);
        $.publish('/filter/' + filter + '/', {
          e: e,
          data: $(e.target).val()
        })
      });

      // Listen for scheme change:
      //  - clear selected indexes
      //  - show / hide
      $.subscribe('/scheme/change/', function(e, data) {
        self.resetSelectIndex();

        var $el = $(self.element);
        var schemeAttr = $el.data('scheme');
        if (!schemeAttr) {
          return;
        }

        // The element will show / hide itself
        schemeAttr === data.scheme ? $el.show() : $el.hide();
      });
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