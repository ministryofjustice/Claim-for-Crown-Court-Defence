"user strict";

var $offenceSelect;
var $offenceClassSelect;

function cascadeOffenceClassChange(){
  offenceClassLabel = $offenceClassSelect.find('option:selected').text();
  if (offenceClassLabel){
    $offenceSelect.children('optgroup').hide();
    $offenceSelect.val("");
    $offenceSelect.children('optgroup[label="' + offenceClassLabel + '"]').show();
  }
}

$( document ).ready(function() {
    $offenceSelect = $('#claim_offence_id');
    $offenceClassSelect = $('#claim_offence_class_id');
    $offenceSelect.children('optgroup').hide();
    $offenceClassSelect.change(function(){
      cascadeOffenceClassChange();
    });
});