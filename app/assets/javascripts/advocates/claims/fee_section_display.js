"use strict";

var adp = adp || {};

adp.feeSectionDisplay = {

  $caseTypeSelect: {},
  $basicFeesSet: {},
  $fixedFeesSet: {},
  $expenseSet: {},
  $miscFeesSet: {},
  $vatApplyChkbox: {},
  $vatReport: {},
  regex: {},
  init : function() {

    //This relates to adp.feeSectionDisplay
    var $this = adp.feeSectionDisplay;

    //initialise handles
    $this.$caseTypeSelect = $('#claim_case_type_id');
    //Initial Fees
    var $basicFeesSet = $this.$basicFeesSet = $('#basic-fees').closest('fieldset'),
    //Fixed Fees Section
    $fixedFeesSet = $this.$fixedFeesSet = $('#fixed-fees').closest('fieldset'),
    //Miscellaneous Fees Section
    $miscFeesSet = $this.$miscFeesSet  = $('#misc-fees').closest('fieldset'),
    //Expenses Section
    $expenseSet = $this.$expenseSet = $('#expenses').closest('fieldset');
    //Apply VAT checkbox
    $this.$vatApplyChkbox = $('#claim_apply_vat');
    // VAT Report Section
    $this.$vatReport = $('#vat-report');

    // add change listener
    $this.$caseTypeSelect.change(function(){
      $this.addCaseTypeChangeEvent();
    });

    // add change listener
    $this.$vatApplyChkbox
    .add($basicFeesSet)
    .add($fixedFeesSet)
    .add($miscFeesSet)
    .add($expenseSet)
      .on('change',':checkbox,.amount,.rate, #expenses .quantity',function(){
        $this.applyVAT();
      });

    //Show the VAT report if "Apply VAT"is checked
    $this.showHideVAT();

    // show the relevant fees fieldset if case type already selected (i.e. if editing existing claim)
    var is_fixed_fee = $('#claim_case_type_id').find(":selected").data('is-fixed-fee');
    $this.applyFixedFeeState(is_fixed_fee == true)

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
    var is_fixed_fee = $('#claim_case_type_id').find(":selected").data('is-fixed-fee');
    adp.feeSectionDisplay.applyFixedFeeState(is_fixed_fee == true)
  },

  showHideVAT :function(){
    var $this = adp.feeSectionDisplay;

    if($this.$vatApplyChkbox.is(':checked')){
      $this.$vatReport.show();
    }else{
      $this.$vatReport.hide();
    };
  },

  getVAT :function(){
    var $this = this;
    return $.ajax({
      url: $this.$vatReport.data('vat-url'),
      data: { "date": $this.$vatReport.data('submitted-date'),
               "net_amount": adp.feeCalculator.totalFee() }
    });
  },
  applyVAT : function(){
    var $this = this,
    $vatReport = $this.$vatReport;

    if($this.$vatApplyChkbox.is(':checked')){

      $.when($this.getVAT())
      .then(function( data, textStatus, jqXHR ){
        $vatReport.find('.vat-date').text(data.date);
        $vatReport.find('.vat-rate').text(data.rate);
        $vatReport.find('.vat-total').text(data.net_amount);
        $vatReport.find('.vat-amount').text(data.vat_amount);
      })
      .then(function(){
        if($vatReport.filter(':visible').length === 0){
          $this.showHideVAT();
        };
      });
    }else{
      $this.showHideVAT();
    };
  }
};
