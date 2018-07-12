moj.Modules.FeeCalculator = {

  init: function () {
    var self = this;
    this.bindEvents();
  },

  bindEvents: function () {
    this.advocateTypeChange();
    this.fixedFeeTypeChange();
  },

  fixedFeeTypeChange: function () {
    var self = this;
    if ($('.calculated-fixed-fee').exists()) {
      $('.js-fixed-fee-calculator-effector-closest').change( function(e) {
        self.calculateUnitPriceFixedFee();
      });
    }
  },

  advocateTypeChange: function () {
    var self = this;
    if ($('.calculated-fixed-fee').exists()) {
      $('.js-fixed-fee-calculator-effector-all').change( function(e) {
        self.calculateUnitPriceFixedFee();
      });
    }
  },

  populateInput: function(selector, data) {
    $effectee = $(selector).find('input.form-control');
    $effectee.val(data.toFixed(2));
    $effectee.change();
  },

  // FIXME: displayFee kept in for example use only as one option is to display the
  // the fee value/unit price. can be got rid off once we know what we are
  // doing.
  displayFee: function(selector, data) {
    data = '&pound;' + moj.Helpers.SideBar.addCommas(data.toFixed(2));
    calculate_html = '<div style="color: #2b8cc4; font-weight: bold;"> Calculated to be: ' + data + '<div>';
    original_label = $(selector + ' label').text().replace(/ \Calculated to be: .*/g,'');
    new_label = original_label + ' ' + calculate_html;
    $(selector + ' label').html(new_label);
  },

  displayError: function(selector, response) {
    // only some errors will have a JSON response
    try { console.log(response.responseJSON.errors); } catch(e) {}
    this.clearErrors(selector);
    $(selector).find('.form-group').addClass('field_with_errors form-group-error');
    error_html = '<div class="js-calculate-error" style="color: #b10e1e; font-weight: bold;">' + response.responseJSON["message"] +'<div>';
    original_label = $(selector + ' label').text()
    new_label = original_label + ' ' + error_html;
    $(selector + ' label').html(new_label);
  },

  clearErrors: function(selector) {
    $(selector).find('.form-group').removeClass('field_with_errors form-group-error');
    $(selector).find('.js-calculate-error').remove();
  },

  unitPriceAjax: function (data) {
    return $.ajax({
      type: 'GET',
      url: '/external_users/claims/' + data['claim_id'] + '/calculate_unit_price.json',
      data: data,
      dataType: 'json'
    });
  },

  // Calculates the "unit price" for a given fixed fee,
  // including fixed fee case uplift fee types.
  calculateUnitPriceFixedFee: function () {
    var self = this;
    // if it was an advocate type change we need to recalculate all
    // unit prices - .js-fixed-fee-calculator-effectee
    // if it was a fee type change we only need to calculate the unit
    // price of the closest input to the event target
    //
    data = {
      claim_id: $('#claim-form').data('claimId'),
      advocate_category: $("input:radio[name='claim[advocate_category]']:checked").val(),
      fee_type_id: $('.js-fee-type').val(),
    }

    self.unitPriceAjax(data)
      .done(function(response) {
        self.clearErrors('.js-fixed-fee-calculator-effectee');
        self.populateInput('.js-fixed-fee-calculator-effectee', response.data["amount"]);
      })
      .fail(function(response) {
        self.displayError('.js-fixed-fee-calculator-effectee', response);
      });
  }
};
