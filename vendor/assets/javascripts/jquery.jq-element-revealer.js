/*! jq-element-revealer - v1.0.6 - 2015-02-20
 * https://github.com/cleargif/jq-element-revealer
 * Copyright (c) 2015 @ClearGif; Licensed http://cleargifltd.mit-license.org/ */
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

  var pluginName = 'jqReveal',
    defaults = {
      arraySeparator: '|',

      // Publisher default selectors and attributes
      publishDelegateSelector: '.jqr-delegate-hook',
      publisherSelector: '.jqr-publisher',
      publisherEvents: 'data-jqr-publish-events',
      publisherEventValue: 'data-jqr-publish-value',

      // Subscriber default selectors and attributes
      subscriberSelector: '.jqr-subscriber',
      subscriberEvents: 'data-jqr-subscribe-events',
      subscriberEventValues: 'data-jqr-subscribe-values',
      triggerPubsAfterBind: true,
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
      this.bindPublishers();
      this.bindSubscribers();
      if (this.settings.triggerPubsAfterBind) {
        this.triggerPublishers();
      }
    },
    /**
     * [bindPublishers description]
     * @return {[type]} [description]
     */
    bindPublishers: function() {
      var $this = $(this.settings.publishDelegateSelector),
        _this = this;

      /**
       * [description]
       * @param  {[type]} e [description]
       * @return {[type]}   [description]
       */
      $this.on('click pseudo-click', _this.settings.publisherSelector, {}, function(e) {
        var $el = $(this),
          $elEventsArray = _this.extractEventNamesList($el, this),
          tag = $el.prop('tagName');
        if (tag === 'A' || tag === 'BUTTON') {
          e.preventDefault();
        }

        $.each($elEventsArray, function(idx, eventName) {
          _this.publish(eventName, e);
        });
      });
    },

    /**
     * [publish description]
     * @param  {[type]} data [description]
     * @param  {[type]} e    [description]
     * @return {[type]}      [description]
     */
    publish: function(data, e) {
      var $el = $(e.target)[0];
      var eventValue = $el.getAttribute('value') || $el.getAttribute(this.settings.publisherEventValue);
      $.publish(data, {
        e: e,
        eventValue: eventValue
      });
    },

    /**
     * [bindSubscribers description]
     * @return {[type]} [description]
     */
    bindSubscribers: function() {
      var $this = $(this.settings.subscriberSelector),
        _this = this;

      $this.is(function(idx, el) {
        $.subscribe(el.getAttribute(_this.settings.subscriberEvents), function(event, obj) {
          _this.subscriberStateManager(el, event, obj);
        });
      });
    },

    /**
     * [subscriberStateManager description]
     * @param  {[type]} el    [description]
     * @param  {[type]} event [description]
     * @param  {[type]} obj   [description]
     * @return {[type]}       [description]
     */
    subscriberStateManager: function(el, event, obj) {
      var eventValues = el.getAttribute(this.settings.subscriberEventValues);
      var isInArray;
      var $el = $(el);
      var publishers;

      if (!eventValues) {
        $el.toggle();
        return;
      }

      isInArray = !!~$.inArray(obj.eventValue, eventValues.split(this.settings.arraySeparator));

      if (isInArray) {
        $el.show();
        return;
      }

      publishers = $el.find('.jqr-publisher');

      if(publishers.length){
        publishers.each(function(idx, el){
          var $_el = $(el);
          if($_el.is(':checked')){
            $_el.trigger('click');
          }
        });
      }
      $el.hide();
    },

    /**
     * [extractEventNamesList description]
     * @param  {[type]} $el   [description]
     * @param  {[type]} _this [description]
     * @return {[type]}       [description]
     */
    extractEventNamesList: function($el, _this) {
      var tagName = $el.prop('tagName'),
        el = ((tagName === 'SELECT') ? $('option:selected', _this)[0] : $el[0]),
        dataArray = el.getAttribute(this.settings.publisherEvents).split(this.settings.arraySeparator);
      return dataArray;
    },

    /**
     * [triggerPublishers description]
     * @return {[type]} [description]
     */
    triggerPublishers: function() {
      $(this.settings.publisherSelector).is(function() {
        var $el = $(this);
        if ($el.is(':checked')) {
          $el.trigger('pseudo-click');
        }
      });
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