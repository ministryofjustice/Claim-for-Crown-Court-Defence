(function (factory) {
  if (typeof define === 'function' && define.amd) {
    // AMD. Register as an anonymous module.
    define(['jquery'], factory)
  } else if (typeof exports === 'object') {
    // Node/CommonJS
    factory(require('jquery'))
  } else {
    // Browser globals
    factory(jQuery)
  }
}(function ($, undefined) {
  'use strict'

  const pluginName = 'numberedList'
  const defaults = {
    wrapper: '.fx-numberedList-wrapper',
    item: '.fx-numberedList-item',
    number: '.fx-numberedList-number',
    action: '.fx-numberedList-action'
  }
  let activated = false

  // Plugin constructor
  function Plugin (options) {
    this.settings = $.extend({}, defaults, options)
    this.init()
  }

  // Avoid Plugin.prototype conflicts
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
        insertedItem.find('.remove_fields:first').focus()
      })

      $(el).on('cocoon:after-remove', function (e) {
        self.updateNumbers()
      })
    },
    updateNumbers: function () {
      const self = this
      const number = self.settings.number
      const action = self.settings.action
      const items = $(this.settings.wrapper).find(this.settings.item + ':visible')

      items.each(function (idx, el) {
        $(el).find(action).removeClass('govuk-!-display-none')
        $(el).find(number).text('')
        if (items.length > 1) {
          $(el).find(number).text(idx + 1)
        }
      })
    }
  })

  // Plugin wrapper to prevent multiple copies of the
  // plugin being included and to prevent it running
  // multiple times
  if (typeof $[pluginName] === 'undefined') {
    $[pluginName] = function (options) {
      if (!activated) {
        new Plugin(options)
        activated = true
      }

      // chain jQuery functions
      return this
    }
  }
}))
