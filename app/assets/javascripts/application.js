// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require select2
//= require cocoon
//= require dropzone
//= require moj
//= require_tree .

/*For JSHint to ignore ADP object*/
/* globals adp */
var moj = moj || {};

moj.Modules.devs.init = function(){};


$('#claim-accordion h2').each(function(){
  $(this).next('section').hide();
  $(this).click(function(){
    $(this).toggleClass('open').next('section').slideToggle('slow');
  });
});
$('#claim-accordion h2:first-of-type').addClass('open').next('section').show();

function initialise(){
  $('.select2').select2();
  adp.newClaim.init();
  adp.crackedTrial.init();
  adp.trialFieldsDisplay.init();
  adp.feeSectionDisplay.init();
  adp.feeCalculator.init('expenses');
  adp.determination.init('determinations');
  adp.dropzone.init();
  moj.Modules.fileUpload.init();
  moj.Modules.judicialApportionment.init();
  moj.Modules.amountAssessed.init();
  $('#fixed-fees, #misc-fees, #expenses, #documents').on('cocoon:after-insert', function(e,insertedItem) {
    $(insertedItem).find('.select2').select2();
  });
  moj.Modules.selectAll.init();
  moj.Modules.allocationFilterSubmit.init();
}


$( document ).ready(function() {
  initialise();

  //Stops the form from submitting when the user presses 'Enter' key
  $("#claim-form form").on("keypress", function (e) {
    if (e.keyCode === 13) {
        return false;
    }
  });
});
