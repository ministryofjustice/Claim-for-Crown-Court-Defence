//= require jquery
//= require jquery_ujs
//= require jquery.remotipart
//= require select2
//= require cocoon
//= require dropzone
//= require vendor/polyfills/bind
//= require govuk/selection-buttons
//= require govuk/stick-at-top-when-scrolling
//= require govuk/stop-scrolling-at-footer
//= require moj
//= require modules/moj.cookie-message.js
//= require_tree .

(function () {
  'use strict';
  delete moj.Modules.devs;

  $('#fixed-fees, #misc-fees, #expenses, #documents').on('cocoon:after-insert', function (e, insertedItem) {
    $(insertedItem).find('.select2').select2();
  });
  $('.select2').select();

  //Stops the form from submitting when the user presses 'Enter' key
  $('#claim-form, #claim-status').on('keypress', function(e) {
    if (e.keyCode === 13) {
      return false;
    }
  });

  var selectionButtons = new GOVUK.SelectionButtons("label input[type='radio'], label input[type='checkbox']");

  GOVUK.stickAtTopWhenScrolling.init();

  moj.init();
}());
