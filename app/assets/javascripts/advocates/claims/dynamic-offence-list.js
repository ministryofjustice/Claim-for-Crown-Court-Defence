"use strict";

var adp = adp || {};

adp.newClaim = {

  $offenceSelect: {},
  $offenceClassSelect: {},
  init : function() {

    //initialise handles
    adp.newClaim.$offenceSelect = $('#claim_offence_id');
    adp.newClaim.$offenceClassSelect = $('#claim_offence_class_id');

    //hide all optgroups
    $(adp.newClaim.$offenceSelect.children('optgroup').select2("container")).removeClass("show-optgroup").addClass("hide-optgroup");
    adp.newClaim.$offenceClassSelect.change(function(){
      adp.newClaim.cascadeOffenceClassChange();
    });

    // set the select offence class group to be that which matches the offence OR ""
    var matchingOffenceClassLabel = adp.newClaim.$offenceSelect.find('option:selected').parent().attr('label');
    if (typeof matchingOffenceClassLabel !== "undefined")  {
      adp.newClaim.$offenceClassSelect.select2('data', { text: matchingOffenceClassLabel });
    }

  },
  cascadeOffenceClassChange : function() {
    var offenceClassLabel = adp.newClaim.$offenceClassSelect.find('option:selected').text();
    if (offenceClassLabel){
      $(adp.newClaim.$offenceSelect.children('optgroup').select2("container")).removeClass("show-optgroup").addClass("hide-optgroup");
      adp.newClaim.$offenceSelect.select2("val", "");
      $(adp.newClaim.$offenceSelect.children('optgroup[label="' + offenceClassLabel + '"]').select2("container")).removeClass("hide-optgroup").addClass("show-optgroup");
    }
  }

};
