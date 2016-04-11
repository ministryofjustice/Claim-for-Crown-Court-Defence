/*
moj.Modules.FeeSectionDisplay = {
  $caseTypeSelect: {},
  $basicFeesSet: {},
  $fixedFeesSet: {},
  $expenseSet: {},
  $miscFeesSet: {},
  regex: {},

  init : function() {
    //This relates to moj.Modules.FeeSectionDisplay
    var self = this;

    //initialise handles
    self.$caseTypeSelect = $('#claim_case_type_id');
    //Initial Fees
    self.$basicFeesSet = $('#basic-fees');
    self.$fixedFeesSet = $('#fixed-fees');
    self.$miscFeesSet = $('#misc-fees');
    self.$expenseSet = $('#expenses');

    // add change listener
    self.$caseTypeSelect.change(function(){
      self.addCaseTypeChangeEvent();
    });

    // show the relevant fees fieldset if case type already selected (i.e. if editing existing claim)
    var is_fixed_fee = $('#claim_case_type_id').find(':selected').data('is-fixed-fee');
    self.applyFixedFeeState(is_fixed_fee === true);
  },

  caseTypeSelected : function () {
    return this.$caseTypeSelect.find('option:selected').text();
  },

  applyWarning : function (warningText, isFixedFee) {

    function feeExists (container) {
      // if there is 1 or more amount input elements with value attribute containing digits 1 to 9
      return $(container).find('.amount')
        .filter( function (index, el) {
          return /[1-9]/.test($(el).text());
        }).length > 0;
    }

    var warningId   = 'fee-deletion-warning';
    var warningMsg  = '<div id="' + warningId + '" class="warning">Warning: ' + warningText + '</div>';
    var $warning    = $('#'+warningId);

    $warning.remove();

    if (isFixedFee && (feeExists('.basic-fee-group'))) {
      this.$caseTypeSelect.after(warningMsg);
    } else if (!isFixedFee && feeExists('.fixed-fee-group')) {
      this.$caseTypeSelect.after(warningMsg);
    }

  },

  applyFixedFeeState : function(state) {
    if (state) {
      this.applyWarning('Initial fees exist that will be removed if you save this claim as a Fixed Fee', state);
      this.$basicFeesSet.slideUp();
      this.$fixedFeesSet.slideDown();

    } else {
      this.applyWarning('Fixed fees exist that will be removed if you save this non-fixed-fee case type claim', state);
      this.$basicFeesSet.slideDown();
      this.$miscFeesSet.slideDown();
      this.$fixedFeesSet.slideUp();
    }
  },

  addCaseTypeChangeEvent : function() {
    var is_fixed_fee = $('#claim_case_type_id').find(':selected').data('is-fixed-fee');
    this.applyFixedFeeState(is_fixed_fee === true);
  }

};
*/
