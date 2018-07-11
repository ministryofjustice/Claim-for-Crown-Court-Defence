moj.Modules.FeeCalculator = {

  init: function () {
    var self = this;
    this.bindEvents();
  },

  bindEvents: function () {
    this.fixedFeeChange();
  },

  fixedFeeChange: function () {
    var self = this;
    if ($('.calculated-fixed-fee').exists()) {
      $('.js-fixed-fee-calculator-effector').change( function(e) {
        self.calculateUnitPriceFixedFee();
      });
    }
  },

  populateInput: function(selector, data) {
    $effectee = $(selector).find('input.form-control');
    $effectee.val(data.toFixed(2));
    $effectee.change();
  },

  // FIXME: kept in for example use only as one option is to display the
  // the fee value/unit price. can be got rid off once we know what we are
  // doing.
  displayFee: function(selector, data) {
    data = '&pound;' + moj.Helpers.SideBar.addCommas(data.toFixed(2));
    calculate_html = '<div style="color: #2b8cc4; font-weight: bold;"> Calculated to be: ' + data + '<div>';
    original_label = $(selector + ' label').text().replace(/ \Calculated to be: .*/g,'');
    new_label = original_label + ' ' + calculate_html;
    $(selector + ' label').html(new_label);
  },

  // Calculates the "total" fee
  // i.e. quantity for unit * "basic/base" fee
  //
  calculateFixedFee: function () {
    var self = this;
    claim_id = $('#claim-form').data('claimId');
    advocate_category = $("input:radio[name='claim[advocate_category]']:checked").val();
    fee_type_id = $('.js-fee-type').val();
    quantity = $('.js-fee-quantity').val();

    $.ajax({
      type: 'GET',
      data: { advocate_category: advocate_category, fee_type_id: fee_type_id, quantity: quantity },
      url: '/external_users/claims/' + claim_id + '/calculate_fee.json',
      success: function (data) {
        self.populateInput('.js-fixed-fee-calculator-effectee', data);
      },
      error: function (response) {
        console.log('errors!');
        $.each(response.responseJSON.errors, function(_index, value) {
          console.log(value);
        });
      }
    });
  },

  // Calculates the "unit price" for fee.
  // Another option is just to call calculate_fee.json
  // explicity with 1 for quantity??
  //
  calculateUnitPriceFixedFee: function () {
    var self = this;
    claim_id = $('#claim-form').data('claimId');
    advocate_category = $("input:radio[name='claim[advocate_category]']:checked").val();
    fee_type_id = $('.js-fee-type').val();

    $.ajax({
      type: 'GET',
      data: { advocate_category: advocate_category, fee_type_id: fee_type_id },
      url: '/external_users/claims/' + claim_id + '/calculate_unit_price.json',
      success: function (data) {
        self.populateInput('.js-fixed-fee-calculator-effectee', data);
      },
      error: function (response) {
        console.log('errors!');
        $.each(response.responseJSON.errors, function(_index, value) {
          console.log(value);
        });
      }
    });
  }
};
