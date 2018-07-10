moj.Modules.FeeCalculator = {
  init: function () {
    var self = this;

    // fixed fees
    if ($('.calculated-fixed-fee').exists()) {
      $('.js-fixed-fee-calculator-effector').change(function(event) {
        claim_id = $('#claim-form').data('claimId');
        advocate_category = $("input:radio[name='claim[advocate_category]']:checked").val();
        fee_type_id = $('.js-fee-type').val();
        quantity = $('.js-fee-quantity').val();

        $.ajax({
          type: 'GET',
          data: { claim_id: claim_id, advocate_category: advocate_category, fee_type_id: fee_type_id, quantity: quantity },
          url: '/external_users/claims/' + claim_id + '/calculate_fee.json',
          success: function (data) {
            data = '&pound;' + moj.Helpers.SideBar.addCommas(data.toFixed(2));
            calculate_html = '<div style="color: #2b8cc4; font-weight: bold;"> Calculated to be: ' + data + '<div>';
            original_label = $('.js-fixed-fee-calculator-effectee label').text().replace(/ \Calculated to be: .*/g,'');
            new_label = original_label + ' ' + calculate_html;
            $('.js-fixed-fee-calculator-effectee label').html(new_label);
          },
          fail: function () {
            console.log('failed!');
          }
        });
      });
    }
  }
};
