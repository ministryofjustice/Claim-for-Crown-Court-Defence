//= require jquery
//= require jquery_ujs
//= require jquery.remotipart
//= require cocoon
//= require dropzone
//= require vendor/polyfills/bind
//= require govuk/selection-buttons
//= require govuk/stick-at-top-when-scrolling
//= require govuk/stop-scrolling-at-footer
//= require moj
//= require modules/moj.cookie-message.js
//= require jquery-accessible-accordion-aria.js
//= require typeahead-aria.js
//= require jquery.jq-element-revealer.js
//= require jquery.datatables.min.js
//= require_tree ./modules
//

/* jQuery Tiny Pub/Sub - v0.7 - 10/27/2011
 * http://benalman.com/
 * Copyright (c) 2011 "Cowboy" Ben Alman; Licensed MIT, GPL */

(function($) {

  var o = $({});

  $.subscribe = function() {
    o.on.apply(o, arguments);
  };

  $.unsubscribe = function() {
    o.off.apply(o, arguments);
  };

  $.publish = function() {
    o.trigger.apply(o, arguments);
  };

}(jQuery));


String.prototype.trunc = String.prototype.trunc || function(n) {
  return (this.length > n) ? this.substr(0, n - 1) + '&hellip;' : this;
};

// Simple string interpolation
if (!String.prototype.supplant) {
  String.prototype.supplant = function(o) {
    return this.replace(
      /\{([^{}]*)\}/g,
      function(a, b) {
        var r = o[b];
        return typeof r === 'string' || typeof r === 'number' ? r : a;
      }
    );
  };
}

(function() {
  'use strict';
  delete moj.Modules.devs;

  jQuery.fn.exists = function() {
    return this.length > 0;
  };

  moj.Helpers.token = (function(name) {
    return $('form input[name=' + name + '_token]').val();
  }('authenticity'));

  $('#fixed-fees, #misc-fees, #disbursements, #expenses, #documents').on('cocoon:after-insert', function(e, insertedItem) {
    var $insertedItem = $(insertedItem);
    var insertedSelect = $insertedItem.find('select.typeahead');
    var typeaheadWrapper = $insertedItem.find('.js-typeahead');

    moj.Modules.Autocomplete.typeaheadKickoff(insertedSelect);
    moj.Modules.Autocomplete.typeaheadBindEvents(typeaheadWrapper);
    moj.Modules.MiscFeeFieldsDisplay.addMiscFeeChangeEvent(typeaheadWrapper);
  });

  //Stops the form from submitting when the user presses 'Enter' key
  $('#claim-form, #claim-status').on('keypress', function(e) {
    if (e.keyCode === 13 && (e.target.type !== 'textarea' && e.target.type !== 'submit')) {
      return false;
    }
  });

  var selectionButtons = new GOVUK.SelectionButtons("label input[type='radio'], label input[type='checkbox']");

  GOVUK.stickAtTopWhenScrolling.init();

  moj.init();
}());