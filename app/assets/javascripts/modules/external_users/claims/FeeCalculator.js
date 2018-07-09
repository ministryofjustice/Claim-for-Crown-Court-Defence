moj.Modules.FeeCalculator = {
  init: function () {
    var self = this;

    if ($('.calculated-fee').exists()) {
      $('.js-calculator-effector').change(function(event) {
        claim_id = $('#claim-form').data('claimId');
        fee_type_id = $('.js-fee-type').val();
        quantity = $('.js-fee-quantity').val();

        $.ajax({
          type: 'GET',
          data: { claim_id: claim_id, fee_type_id: fee_type_id, quantity: quantity },
          url: '/external_users/claims/' + claim_id + '/calculate_fee.json',
          success: function (data) {
            data = '&pound;' + moj.Helpers.SideBar.addCommas(data.toFixed(2));
            calculate_prefix = ' (Calculated to be: ';
            calculate_suffix = data + ')';
            label_text = $('.js-calculator-effectee label').text().replace(/ \(Calculated to be: .*\)/g,'') + calculate_prefix + calculate_suffix;
            $('.js-calculator-effectee label').html(label_text)
          }
        });
      });
    }
  }
};
