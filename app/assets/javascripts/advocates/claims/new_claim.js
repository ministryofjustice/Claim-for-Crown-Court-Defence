"use strict";

var cbo = cbo || {}

cbo.newClaim = {

  $offenceSelect: {},
  $offenceClassSelect: {},
  init : function() {
    cbo.newClaim.$offenceSelect = $('#claim_offence_id');
    cbo.newClaim.$offenceClassSelect = $('#claim_offence_class_id');

    $(cbo.newClaim.$offenceSelect.children('optgroup').select2("container")).removeClass("show-optgroup").addClass("hide-optgroup");
    cbo.newClaim.$offenceClassSelect.change(function(){
      cbo.newClaim.cascadeOffenceClassChange();
    });
  },
  cascadeOffenceClassChange : function() {
    offenceClassLabel = cbo.newClaim.$offenceClassSelect.find('option:selected').text();
    if (offenceClassLabel){
      $(cbo.newClaim.$offenceSelect.children('optgroup').select2("container")).removeClass("show-optgroup").addClass("hide-optgroup");
      cbo.newClaim.$offenceSelect.val("");
      $(cbo.newClaim.$offenceSelect.children('optgroup[label="' + offenceClassLabel + '"]').select2("container")).removeClass("hide-optgroup").addClass("show-optgroup");
    }
  }
  
}
