"use strict";

var adp = adp || {};

adp.trialFieldsDisplay = {

  $caseTypeSelect: {},
  $container: {},
  regex: {},
  init : function() {

    //initialise handles
    adp.trialFieldsDisplay.$caseTypeSelect = $('#claim_case_type_id');
    adp.trialFieldsDisplay.$container = $('#trial-details');
    adp.trialFieldsDisplay.regex = /(Appeal against conviction|Appeal against sentence|Breach of Crown Court order|Commital for Sentence|Contempt|Cracked Trial|Cracked before retrial|Elected cases not proceeded).*/i;

    // add change listener
    adp.trialFieldsDisplay.$caseTypeSelect.change(function(){
      adp.trialFieldsDisplay.addCaseTypeChangeEvent();
    });

    adp.trialFieldsDisplay.addCaseTypeChangeEvent();
  },
  addCaseTypeChangeEvent : function() {
    var caseTypeLabel = adp.trialFieldsDisplay.$caseTypeSelect.find('option:selected').text();
    if (caseTypeLabel) {
      if (adp.trialFieldsDisplay.regex.test(caseTypeLabel) || adp.trialFieldsDisplay.$caseTypeSelect.val() == '') {
        adp.trialFieldsDisplay.$container.hide();
      } else {
        adp.trialFieldsDisplay.$container.slideDown();
      }
    }
  }

};
