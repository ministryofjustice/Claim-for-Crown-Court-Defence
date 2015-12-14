// Description:
//  The number/quantity of daily attendance fees are based
//  on the number of days the advocate attended court.
//  This JS populates the DAF quantities based on the
//  user-specified trial length to a. avoid user error
//  and b. simplify form completion.
//
moj.Modules.FeePopulator = {
  $actualTrialLength: {},
  $dafQuantity: {},
  $dahQuantity: {},
  $dajQuantity: {},

  init : function() {
    var self = this;

    self.$actualTrialLength = $('#claim_actual_trial_length');
    $dafQuantity = $('#claim_basic_fees_attributes_1_quantity');
    $dahQuantity = $('#claim_basic_fees_attributes_2_quantity');
    $dajQuantity = $('#claim_basic_fees_attributes_3_quantity');

    self.$actualTrialLength.change(function(){
      self.actualTrialLengthChanged();
    });
  },

  actualTrialLengthChanged : function() {
    var l = this.$actualTrialLength.val();
    var daf = l-2  <= 0 ? 0 : Math.min(l,40)-2;
    var dah = l-40 <= 0 ? 0 : Math.min(l,50)-40;
    var daj = l-50 <= 0 ? 0 : l-50;

    //form displays 0 as empty string
    $dafQuantity.val(daf <= 0 ? '' : daf);
    $dahQuantity.val(dah <= 0 ? '' : dah);
    $dajQuantity.val(daj <= 0 ? '' : daj);
  }

};
