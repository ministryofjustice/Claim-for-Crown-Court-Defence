(function ($, window, document, _undefined) {
  const pluginName = 'dtFilter'
  const defaults = {}

  // The actual plugin constructor
  function Plugin (element, options) {
    this.element = element
    this.options = $.extend({}, defaults, options)
    this._defaults = defaults
    this._name = pluginName

    this.init()
  }

  Plugin.prototype = {

    /**
     * Method called internally
     * @return {Object} Return `this` to maintain chaining (?)
     */
    init: function () {
      this.bindEvents()
      return this
    },
    /**
     * Rest this control's selected index to 0
     */
    resetSelectIndex: function () {
      $(this.element).find('select').prop('selectedIndex', 0)
    },

    /**
     * Bind all the events
     */
    bindEvents: function () {
      const self = this

      // Listen for clear event
      $.subscribe('/general/clear-filters/', function () {
        self.resetSelectIndex()
      })

      // Listen for scheme change and clear index
      $.subscribe('/scheme/change/', function () {
        self.resetSelectIndex()
      })

      // publish the events with filter specific data
      $(this.element).on('change', 'select', function (e) {
        const filter = $(e.target).attr('name')
        $.publish('/general/change/', filter)
        $.publish('/filter/' + filter + '/', {
          e,
          data: $(e.target).val()
        })
      })

      // Listen for scheme change:
      //  - clear selected indexes
      //  - show / hide
      $.subscribe('/scheme/change/', function (e, data) {
        self.resetSelectIndex()

        const $el = $(self.element)
        const schemeAttr = $el.data('scheme')
        if (!schemeAttr) {
          return
        }

        // The element will show / hide itself
        schemeAttr === data.scheme ? $el.removeClass('hidden') : $el.addClass('hidden')
      })
    }
  }

  $.fn[pluginName] = function (options) {
    return this.each(function () {
      if (!$.data(this, 'plugin_' + pluginName)) {
        $.data(this, 'plugin_' + pluginName,
          new Plugin(this, options))
      }
    })
  }
})(jQuery, window, document)
