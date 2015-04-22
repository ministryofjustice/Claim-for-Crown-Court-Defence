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
//= require turbolinks
//= require cocoon
//= require_tree .
$('#claims-list dd, dt').not('.quickview').each(function() {
  $(this).hide();
});

$('#claims-list .toggle').each(function(){
   $(this).click(function() {
    $(this).toggleClass('expanded').closest('li').find('dd, dt').not('.quickview').slideToggle('slow');   
  });
});

$('#claim-accordian h2').each(function(){
  $(this).next('section').hide();
  $(this).click(function(){
    $(this).toggleClass('open').next('section').slideToggle('slow');
  });
});
$('#claim-accordian h2:first-of-type').addClass('open').next('section').show();