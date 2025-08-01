(function ($) {
  'use strict'

  const pluginName = 'numberedList'
  const defaults = {
    wrapper: '.fx-numberedList-hook',
    item: '.fx-numberedList-item',
    number: '.fx-numberedList-number',
    action: '.fx-numberedList-action'
  }
  let activated = false

  function Plugin (options) {
    this.settings = $.extend({}, defaults, options)
    this.init()
  }

  $.extend(Plugin.prototype, {
    init: function () {
      if ($(this.settings.wrapper).length >= 1) {
        this.bindListeners()
        this.updateNumbers()
      }
    },
    bindListeners: function () {
      const self = this
      const el = '#' + $(this.settings.wrapper).attr('id')
      if (el === '#undefined') {
        throw Error('This is an error message')
      }

      $(el).on('cocoon:after-insert', function (e, insertedItem) {
        self.updateNumbers()
        insertedItem.find('.remove_fields:first').trigger('focus')
      })

      $(el).on('cocoon:after-remove', function (e) {
        self.updateNumbers()
      })
    },
    updateNumbers: function () {
      const self = this
      const number = self.settings.number
      const action = self.settings.action
      const items = $(this.settings.wrapper).find(this.settings.item)

      items.each(function (idx, el) {
        $(el).find(action).removeClass('govuk-!-display-none')
        $(el).find(number).text('')
        if (items.length > 1) {
          $(el).find(number).text(idx + 1)
        }
      })
    }
  })

  $.fn[pluginName] = function (options) {
    if (!activated) {
      new Plugin(options).init()
      activated = true
    }
    return this
  }
})(jQuery)
