"use strict";

var adp = adp || {};

adp.feeSectionDisplay = {

  $caseTypeSelect: {},
  $basicFeesSet: {},
  $fixedFeesSet: {},
  $miscFeesSet: {},
  regex: {},
  init : function() {

    //initialise handles
    adp.feeSectionDisplay.$caseTypeSelect = $('#claim_case_type');
    adp.feeSectionDisplay.regex = /Fixed fee/;
    adp.feeSectionDisplay.$basicFeesSet = $('#basic-fees').parents('fieldset');
    adp.feeSectionDisplay.$fixedFeesSet = $('#fixed-fees').parents('fieldset');
    adp.feeSectionDisplay.$miscFeesSet  = $('#misc-fees').parents('fieldset');

    // add change listener
    adp.feeSectionDisplay.$caseTypeSelect.change(function(){
      adp.feeSectionDisplay.addCaseTypeChangeEvent();
    });

    // show the relevant fees fieldset if case type already selected (i.e. if editing existing claim)
    adp.feeSectionDisplay.applyFixedFeeState(adp.feeSectionDisplay.regex.test(adp.feeSectionDisplay.caseTypeSelected()));
  },

  caseTypeSelected : function () {
    return adp.feeSectionDisplay.$caseTypeSelect.find('option:selected').text();
  },

  applyWarning : function (warningText, isFixedFee) {

    function feeExists (container) {
        // if there is 1 or more amount input elements with value attribute containing digits 1 to 9
        return $(container).find('.amount')
                  .filter( function (index, el) {
                    return /[1-9]/.test($(el).val());
                  }).length > 0;
    }

    var warningId   = 'fee-deletion-warning';
    var warningMsg  = "<div id='" + warningId + "' class='warning'>Warning: " + warningText +"</div>";
    var $warning    = $('#'+warningId);

    $warning.remove();

    if (isFixedFee && (feeExists('.basic-fee-group') || feeExists('.misc-fee-group'))) {
      adp.feeSectionDisplay.$caseTypeSelect.after(warningMsg);
    } else if (!isFixedFee && feeExists('.fixed-fee-group')) {
      adp.feeSectionDisplay.$caseTypeSelect.after(warningMsg);
    }

  },

  applyFixedFeeState : function(state) {
    if (state) {
      adp.feeSectionDisplay.applyWarning('Initial and Miscellaneous fees exist that will be removed if you save this claim as a Fixed Fee!', state);
      adp.feeSectionDisplay.$basicFeesSet.slideUp();
      adp.feeSectionDisplay.$miscFeesSet.slideUp();
      adp.feeSectionDisplay.$fixedFeesSet.slideDown();

    } else {
      adp.feeSectionDisplay.applyWarning('Fixed fees exist that will be removed if you save this non-fixed-fee case type claim!', state);
      adp.feeSectionDisplay.$basicFeesSet.slideDown();
      adp.feeSectionDisplay.$miscFeesSet.slideDown();
      adp.feeSectionDisplay.$fixedFeesSet.slideUp();
    }
  },

  addCaseTypeChangeEvent : function() {
    adp.feeSectionDisplay.applyFixedFeeState(adp.feeSectionDisplay.regex.test(adp.feeSectionDisplay.caseTypeSelected()));
  }

};
