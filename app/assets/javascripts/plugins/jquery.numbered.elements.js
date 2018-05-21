(function(factory) {
  if (typeof define === 'function' && define.amd) {
    // AMD. Register as an anonymous module.
    define(['jquery'], factory);
  } else if (typeof exports === 'object') {
    // Node/CommonJS
    factory(require('jquery'));
  } else {
    // Browser globals
    factory(jQuery);
  }
}(function($, undefined) {
  'use strict';

  var pluginName = 'numberedList',
    defaults = {
      wrapper: '.fx-' + pluginName + '-wrapper',
      item: '.fx-' + pluginName + '-item',
      number: '.fx-' + pluginName + '-number'
    },
    activated = false;

  // Plugin constructor
  function Plugin(options) {
    this.settings = $.extend({}, defaults, options);
    this.init();
  }

  // Avoid Plugin.prototype conflicts
  $.extend(Plugin.prototype, {
    init: function() {
      if ($(this.settings.wrapper).length >= 1) {
        this.bindListeners();
        this.updateNumbers();
      }
    },
    bindListeners: function() {
      var self = this;
      $(this.settings.wrapper).on('cocoon:after-insert', function(e) {
        self.updateNumbers();
      });

      $(this.settings.wrapper).on('cocoon:after-remove', function(e) {
        self.updateNumbers();
      });
    },
    updateNumbers: function() {
      var self = this;
      $(this.settings.wrapper).find(this.settings.item+':visible').each(function(idx, el) {
        $(el).find(self.settings.number).text(idx+1)
      })
    }
  });

  // Plugin wrapper to prevent multiple copies of the
  // plugin being included and to prevent it running
  // multiple times
  if (typeof $[pluginName] === "undefined") {

    $[pluginName] = function(options) {

      if (!activated) {
        new Plugin(options);
        activated = true;
      }

      // chain jQuery functions
      return this;
    };

  }
}));
