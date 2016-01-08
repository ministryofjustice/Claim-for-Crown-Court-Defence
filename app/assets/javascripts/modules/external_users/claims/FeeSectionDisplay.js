moj.Modules.FeeSectionDisplay = {
  $caseTypeSelect: {},
  $basicFeesSet: {},
  $fixedFeesSet: {},
  $expenseSet: {},
  $miscFeesSet: {},
  $vatApplyChkbox: {},
  $vatReport: {},
  regex: {},

  init : function() {
    //This relates to moj.Modules.FeeSectionDisplay
    var self = this;

    //initialise handles
    self.$caseTypeSelect = $('#claim_case_type_id');
    //Initial Fees
    var $basicFeesSet = self.$basicFeesSet = $('#basic-fees').closest('fieldset');
    var $fixedFeesSet = self.$fixedFeesSet = $('#fixed-fees').closest('fieldset');
    var $miscFeesSet = self.$miscFeesSet = $('#misc-fees').closest('fieldset');
    var $expenseSet = self.$expenseSet = $('#expenses').closest('fieldset');
    //Apply VAT checkbox
    self.$vatApplyChkbox = $('#claim_apply_vat');
    // VAT Report Section
    self.$vatReport = $('#vat-report');

    // add change listener
    self.$caseTypeSelect.change(function(){
      self.addCaseTypeChangeEvent();
    });

    // add change listener
    self.$vatApplyChkbox
    .add($basicFeesSet)
    .add($fixedFeesSet)
    .add($miscFeesSet)
    .add($expenseSet)
      .on('change',':checkbox,.amount,.rate, #expenses .quantity',function(){
        self.applyVAT();
      });

    //Show the VAT report if "Apply VAT"is checked
    self.showHideVAT();

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
  },

  showHideVAT :function(){
    if(this.$vatApplyChkbox.is(':checked')){
      this.$vatReport.show();
    }else{
      this.$vatReport.hide();
    }
  },

  getVAT :function(){
    return $.ajax({
      url: this.$vatReport.data('vat-url'),
      data: {
        date: this.$vatReport.data('submitted-date'),
        net_amount: moj.Modules.FeeCalculator.totalFee()
      }
    });
  },
  applyVAT : function(){
    var $vatReport = this.$vatReport;
    var self = this;

    if(this.$vatApplyChkbox.is(':checked')){

      $.when(this.getVAT())
      .then(function( data){
        $vatReport.find('.vat-date').text(data.date);
        $vatReport.find('.vat-rate').text(data.rate);
        $vatReport.find('.vat-total').text(data.net_amount);
        $vatReport.find('.vat-amount').text(data.vat_amount);
      })
      .then(function(){
        if($vatReport.filter(':visible').length === 0){
          self.showHideVAT();
        }
      });
    }else{
      this.showHideVAT();
    }
  }
};
