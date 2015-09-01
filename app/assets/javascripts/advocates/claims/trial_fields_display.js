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
    adp.trialFieldsDisplay.regex = /[Gg]uilty [Pp]lea.*/;

    // add change listener
    adp.trialFieldsDisplay.$caseTypeSelect.change(function(){
      adp.trialFieldsDisplay.addCaseTypeChangeEvent();
    });

    // hide fields if guilty plea already selected (i.e. if editing existing claim)
    var caseTypeLabel = adp.trialFieldsDisplay.$caseTypeSelect.find('option:selected').text();
    if (typeof caseTypeLabel === "undefined" || adp.trialFieldsDisplay.regex.test(caseTypeLabel)) {
        adp.trialFieldsDisplay.$container.hide();
    }
  },
  addCaseTypeChangeEvent : function() {
    var caseTypeLabel = adp.trialFieldsDisplay.$caseTypeSelect.find('option:selected').text();
    if (caseTypeLabel) {
      if (adp.trialFieldsDisplay.regex.test(caseTypeLabel)) {
        adp.trialFieldsDisplay.$container.slideUp();
      } else {
        adp.trialFieldsDisplay.$container.slideDown();
      }
    }
  }

};
