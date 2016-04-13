// Description:
//  The number/quantity of daily attendance fees are based
//  on the number of days the advocate attended court.
//  This JS populates the DAF quantities based on the
//  user-specified trial or retrial length to
//    a. avoid user error
//    b. simplify form completion.
//
/*
moj.Modules.FeePopulator = {
  $caseTypeSelect: {},
  $actualTrialLength: {},
  $retrialActualLength: {},
  $dafQuantity: {},
  $dahQuantity: {},
  $dajQuantity: {},

  init : function() {
    var self = this;

    self.$caseTypeSelect = $('#claim_case_type_id');
    self.$actualTrialLength = $('#claim_actual_trial_length');
    self.$retrialActualLength = $('#claim_retrial_actual_length');
    self.$dafQuantity = $('#claim_basic_fees_attributes_1_quantity');
    self.$dahQuantity = $('#claim_basic_fees_attributes_2_quantity');
    self.$dajQuantity = $('#claim_basic_fees_attributes_3_quantity');

    self.$actualTrialLength.change(function(e){
      self.trialLengthChanged(e);
    });

    self.$retrialActualLength.change(function(e){
      self.trialLengthChanged(e);
    });
  },

  caseTypeSelected : function () {
    return this.$caseTypeSelect.find('option:selected').text();
  },

  trialLengthChanged : function(e) {
    var self = this;
    if (e) {
      if (self.caseTypeSelected() == 'Retrial' && e.target.id.indexOf('retrial_actual_length') >=0 ) {
        self.popDafQuantities(self.$retrialActualLength.val());
      } else if (self.caseTypeSelected() == 'Trial' && e.target.id.indexOf('actual_trial_length') >=0 ) {
        self.popDafQuantities(self.$actualTrialLength.val());
      }
    }
  },

  popDafQuantities : function (l) {
    var daf  = l-2  <= 0 ? 0 : Math.min(l,40)-2;
    var dah  = l-40 <= 0 ? 0 : Math.min(l,50)-40;
    var daj  = l-50 <= 0 ? 0 : l-50;

    //form displays 0 as empty string
    this.$dafQuantity.val(daf <= 0 ? '' : daf);
    this.$dahQuantity.val(dah <= 0 ? '' : dah);
    this.$dajQuantity.val(daj <= 0 ? '' : daj);
  }

};
*/