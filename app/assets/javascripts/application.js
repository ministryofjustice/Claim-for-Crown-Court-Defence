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
//= require_tree ./modules

(function() {
  'use strict';
  delete moj.Modules.devs;

  jQuery.fn.exists = function() {
    return this.length > 0;
  };

  /*! Tiny Pub/Sub - v0.7.0 - 2013-01-29
   * https://github.com/cowboy/jquery-tiny-pubsub
   * Copyright (c) 2013 "Cowboy" Ben Alman; Licensed MIT */
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

  // Publish the agfs event when provider changes
  // this will show / hide AGFS supplier number
  $.subscribe('/provider/type/', function(e, obj) {
    $.publish('/scheme/type/agfs/', obj);
  });


  // Subscribe to the AGFS event and publish the full state
  // via a proxy listener
  $.subscribe('/scheme/type/agfs/', function(e, obj) {
    var provider = $('#provider_provider_type_chamber').is(':checked') ? 'chamber' : 'firm';
    var $agfs = $('#provider_roles_agfs').is(':checked');
    $.publish('/scheme/type/agfs/proxy/', {
      provider: provider,
      agfs: $agfs
    });
  });

  // Proxy listener to conditionally show / hide the supplier
  // number for agfs
  $.subscribe('/scheme/type/agfs/proxy/', function(event, obj) {
    if(obj.provider === 'firm' && obj.agfs === true){
      $.publish('/scheme/type/agfs/custom/', {eventValue: 'show-agfs-supplier'});
      return;
    }
    $('input#provider_firm_agfs_supplier_number').val('');
    $.publish('/scheme/type/agfs/custom/', {eventValue: 'hide-agfs-supplier'});
  });

  $.jqReveal({
    // options go here
  });

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