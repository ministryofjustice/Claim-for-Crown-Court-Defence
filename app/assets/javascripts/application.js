/*global GOVUK*/
//= require jquery
//= require jquery_ujs
//= require jquery.remotipart
//= require cocoon
//= require dropzone
//= require vendor/polyfills/bind
//= require govuk/stick-at-top-when-scrolling
//= require govuk/stop-scrolling-at-footer
//= require moj
//= require modules/moj.cookie-message.js
//= require jquery-accessible-accordion-aria.js
//= require typeahead-aria.js
//= require jquery.jq-element-revealer.js
//= require jquery.datatables.min.js
//= require jsrender.min.js
//= require jquery.highlight-5.min.js
//= require jquery.ba-throttle-debounce.js
//= require_tree ./modules
//= require_tree ./plugins
//

// TINY PUBSUB
// Great little wrapper to easily do pub/sub

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


// Trunc polyfil
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


  // Where .multiple-choice uses the data-target attribute
  // to toggle hidden content
  var showHideContent = new GOVUK.ShowHideContent();
  showHideContent.init();


  // Sticky sidebar
  // TODO: Re-init / reset the screen dimentions as page expands
  GOVUK.stickAtTopWhenScrolling.init();

  /**
   * Cocoon call back to init features once they have been
   * interted into the DOM
   */
  $('#fixed-fees, #misc-fees, #disbursements, #expenses, #documents').on('cocoon:after-insert', function(e, insertedItem) {
    var $insertedItem = $(insertedItem);
    var insertedSelect = $insertedItem.find('select.typeahead');
    var typeaheadWrapper = $insertedItem.find('.js-typeahead');

    moj.Modules.Autocomplete.typeaheadKickoff(insertedSelect);
    moj.Modules.Autocomplete.typeaheadBindEvents(typeaheadWrapper);
    moj.Modules.FeeFieldsDisplay.addFeeChangeEvent(insertedItem);
  });

  // Basic fees page
  $('#basic-fees').on('change', '.js-block input', function() {
    $(this).trigger('recalculate');
  });

  // this is a bit hacky
  // TODO: To be moved to more page based controllers
  $('#basic-fees').on('change', '.multiple-choice input[type=checkbox]', function(e){
    var checked = $(e.target).is(':checked');
    var fields_wrapper = $(e.target).attr('aria-controls');
    var $fields_wrapper = $('#'+fields_wrapper);

    $fields_wrapper.find('input[type=number]').val(0);
    $fields_wrapper.find('input[type=text]').val('');
    $fields_wrapper.find('.gov_uk_date input[type=number]').val('');
    $fields_wrapper.find('.gov_uk_date input[type=number]').prop('disabled', !checked);
    $fields_wrapper.trigger('recalculate');
  });

  /**
   * Fee calculation event binding for added fees
   */
  $('#fixed-fees').on('cocoon:after-insert', function(e, insertedItem) {
    var $insertedItem = $(insertedItem);

    moj.Modules.FeeCalculator.fixedFeeTypeChange($insertedItem.find('.js-fixed-fee-calculator-fee-type'));
    moj.Modules.FeeCalculator.fixedFeeQuantityChange($insertedItem.find('.js-fixed-fee-calculator-quantity'));
  });

  /**
  * Fee Calculation is inter-fee dependant. When one changes
  * it could have impact on others so all have to be checked.
  */
  $('#fixed-fees').on('cocoon:after-remove', function() {
    moj.Modules.FeeCalculator.calculateUnitPriceFixedFee();
  });

  // Manually hit the `add rep order` button after a
  // cocoon insert.
  $('.form-actions').on('cocoon:after-insert', function(e, el) {
    var $el = $(el);
    if ($el.hasClass('resource-details')) {
      $el.find('a.add_fields').click();
    }
  });

  //Stops the form from submitting when the user presses 'Enter' key
  $('#claim-form, #claim-status').on('keypress', function(e) {
    if (e.keyCode === 13 && (e.target.type !== 'textarea' && e.target.type !== 'submit')) {
      return false;
    }
  });



  moj.Helpers.token = (function(name) {
    return $('form input[name=' + name + '_token]').val();
  }(['au', 'th', 'ent', 'ici', 'ty'].join(''))); //;-)

  moj.init();
  $.numberedList();
}());
