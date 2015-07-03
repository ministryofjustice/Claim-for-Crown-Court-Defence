"use strict";

var adp = adp || {};

adp.crackedTrial = {

  $caseTypeSelect: {},
  $fieldSet: {},
  regex: {},
  init : function() {

    //initialise handles
    adp.crackedTrial.$caseTypeSelect = $('#claim_case_type');
    adp.crackedTrial.$fieldSet = $('#cracked_trial_detail');
    adp.crackedTrial.regex = /[Cc]racked .*/;

    // add change listener
    adp.crackedTrial.$caseTypeSelect.change(function(){
      adp.crackedTrial.addCaseTypeChangeEvent();
    });

    // show fieldset if cracked trial type already selected (i.e. if editing existing claim)
    var caseTypeLabel = adp.crackedTrial.$caseTypeSelect.find('option:selected').text();
    if (typeof caseTypeLabel == "undefined" || !adp.crackedTrial.regex.test(caseTypeLabel)) {
        adp.crackedTrial.$fieldSet.hide();
    }

  },
  addCaseTypeChangeEvent : function() {
    var caseTypeLabel = adp.crackedTrial.$caseTypeSelect.find('option:selected').text();
    if (caseTypeLabel) {
      if (adp.crackedTrial.regex.test(caseTypeLabel)) {
        adp.crackedTrial.$fieldSet.slideDown();
      } else {
        adp.crackedTrial.$fieldSet.slideUp();
      }
    }
  }

};
