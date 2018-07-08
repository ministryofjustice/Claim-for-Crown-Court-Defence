moj.Modules.FeeCalculator = {
  init: function () {
    var self = this;

    if ($('#calculated-fee').exists()) {
      $('.js-calculator-effector').change(function() {
        // alert("effector changed");
        claim_id = $('#claim-form').data('claimId');
        fee_type_id = $('.js-fee-type').val();
        quantity = $('.js-fee-quantity').val();

        $.ajax({
          type: 'GET',
          data: { claim_id: claim_id, quantity: quantity, fee_type_id: fee_type_id },
          url: '/external_users/claims/' + claim_id + '/calculate_fee.js',
          success: function (data) {
            // $('#calculated-fee').html(data);
          }
        });
      });
    }
  }
};
