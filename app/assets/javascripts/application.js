//= require jquery
//= require jquery_ujs
//= require jquery.remotipart
//= require select2
//= require cocoon
//= require dropzone
//= require moj
//= require modules/moj.cookie-message
//= require_tree .

(function () {
  "use strict";

  delete moj.Modules.devs;

  // Accordion
  $('#claim-accordion')
    .find('h2')
      .next('section').hide()
      .parent()
    .on('click', 'h2', function(e, animationDuration) {
      $(this).toggleClass('open').next('section').slideToggle(animationDuration);
    })
    .find('h2:first-of-type').trigger('click', 0);

  $('.select2').select();

  //Stops the form from submitting when the user presses 'Enter' key
  $('#claim-form').on('keypress', function(e) {
    if (e.keyCode === 13) {
      return false;
    }
  });
  
  moj.init();
}());
