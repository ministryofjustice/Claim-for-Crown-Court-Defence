//= require jquery
//= require jquery_ujs
//= require jquery.remotipart
//= require select2
//= require cocoon
//= require dropzone
//= require moj
//= require modules/moj.cookie-message
//= require_tree .

/*For JSHint to ignore ADP object*/
/* globals rorData */

var moj = moj || {};

moj.Modules.devs.init = function(){};

// Accordion
$('#claim-accordion h2').each(function(){
  $(this).next('section').hide();
  $(this).click(function(){
    $(this).toggleClass('open').next('section').slideToggle('slow');
  });
});
$('#claim-accordion h2:first-of-type').addClass('open').next('section').show();


$('#footer').css('margin-top', $(document).height() - ($('#global-header').height() + $('.outer-block:eq(1)').height()  ) - $('#footer').height());

$('#fixed-fees, #misc-fees, #expenses, #documents').on('cocoon:after-insert', function(e, insertedItem) {
  $(insertedItem).find('.select2').select2();
});

//Stops the form from submitting when the user presses 'Enter' key
$("#claim-form form").on("keypress", function (e) {
  if (e.keyCode === 13) {
      return false;
  }
});

moj.init();