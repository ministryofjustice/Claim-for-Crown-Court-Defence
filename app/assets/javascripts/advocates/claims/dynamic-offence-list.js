"use strict";

var cbo = cbo || {}

cbo.newClaim = {

  $offenceSelect: {},
  $offenceClassSelect: {},
  init : function() {

    //initialise handles
    cbo.newClaim.$offenceSelect = $('#claim_offence_id');
    cbo.newClaim.$offenceClassSelect = $('#claim_offence_class_id');

    //hide all optgroups
    $(cbo.newClaim.$offenceSelect.children('optgroup').select2("container")).removeClass("show-optgroup").addClass("hide-optgroup");
    cbo.newClaim.$offenceClassSelect.change(function(){
      cbo.newClaim.cascadeOffenceClassChange();
    });

    // set the select offence class group to be that which matches the offence OR ""
    var matchingOffenceClassLabel = cbo.newClaim.$offenceSelect.find('option:selected').parent().attr('label');
    if (typeof matchingOffenceClassLabel !== "undefined")  {
      cbo.newClaim.$offenceClassSelect.select2('data', { text: matchingOffenceClassLabel });
    }

  },
  cascadeOffenceClassChange : function() {
    var offenceClassLabel = cbo.newClaim.$offenceClassSelect.find('option:selected').text();
    if (offenceClassLabel){
      $(cbo.newClaim.$offenceSelect.children('optgroup').select2("container")).removeClass("show-optgroup").addClass("hide-optgroup");
      cbo.newClaim.$offenceSelect.select2("val", "");
      $(cbo.newClaim.$offenceSelect.children('optgroup[label="' + offenceClassLabel + '"]').select2("container")).removeClass("hide-optgroup").addClass("show-optgroup");
    }
  }

}
