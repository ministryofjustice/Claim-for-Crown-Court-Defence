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

  var pluginName = 'numberedList';
  var defaults = {
      wrapper: '.fx-numberedList-wrapper',
      item: '.fx-numberedList-item',
      number: '.fx-numberedList-number',
      action: '.fx-numberedList-action'
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
      var el = '#' + $(this.settings.wrapper).attr('id');
      if(el === "#undefined"){
        throw Error('This is an error message');
      }

      $(el).on('cocoon:after-insert', function(e) {
        self.updateNumbers();
      });

      $(el).on('cocoon:after-remove', function(e) {
        self.updateNumbers();
      });
    },
    updateNumbers: function() {
      var self = this;
      var items = $(this.settings.wrapper).find(this.settings.item + ':visible');
      if (items.length > 1) {
        items.each(function(idx, el) {
          $(el).find(self.settings.number).text(idx + 1);
          $(el).find(self.settings.action).css('display', 'block');
        });
      } else{
        items.each(function(idx, el) {
          $(el).find(self.settings.number).text('');
          $(el).find(self.settings.action).css('display', 'none');
        });
      }
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
