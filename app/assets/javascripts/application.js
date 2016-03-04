//= require jquery
//= require jquery_ujs
//= require jquery.remotipart
//= require select2
//= require cocoon
//= require dropzone
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

  moj.init();
}());
