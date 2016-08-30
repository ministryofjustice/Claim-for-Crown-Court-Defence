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
//= require awesomplete.js
//= require jquery-ui.min.js
//= require jquery.select-to-autocomplete.js
//= require_tree .

(function () {
  'use strict';
  delete moj.Modules.devs;

  jQuery.fn.exists = function() { return this.length > 0 };

  $('#fixed-fees, #misc-fees, #disbursements, #expenses, #documents').on('cocoon:after-insert', function (e, insertedItem) {
    //$(insertedItem).find('select.autocomplete').AutoComplete();
    $(insertedItem).find('select.autocomplete').selectToAutocomplete();
  });

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
