"user strict";

var cbo = cbo || {}

cbo.newClaim = {

  $offenceSelect: {},
  $offenceClassSelect: {},
  init : function() {
    cbo.newClaim.$offenceSelect = $('#claim_offence_id');
    cbo.newClaim.$offenceClassSelect = $('#claim_offence_class_id');
    cbo.newClaim.$offenceSelect.children('optgroup').hide();
    cbo.newClaim.$offenceClassSelect.change(function(){
      cbo.newClaim.cascadeOffenceClassChange();
    });
  },
  cascadeOffenceClassChange : function() {
    offenceClassLabel = cbo.newClaim.$offenceClassSelect.find('option:selected').text();
    if (offenceClassLabel){
      cbo.newClaim.$offenceSelect.children('optgroup').hide();
      cbo.newClaim.$offenceSelect.val("");
      cbo.newClaim.$offenceSelect.children('optgroup[label="' + offenceClassLabel + '"]').show();
    }
  }
  
}
