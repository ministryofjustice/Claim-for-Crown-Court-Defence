moj.Modules.FeeCalculator = {
  init: function () {
    this.bindEvents();
  },

  bindEvents: function () {
    this.advocateTypeChange();
    this.fixedFeeTypeChange();
    this.fixedFeeQuantityChange();
  },

  advocateTypeChange: function () {
    var self = this;
    if ($('.calculated-fixed-fee').exists()) {
      $('.js-fixed-fee-calculator-advocate-type').change( function() {
        self.calculateUnitPriceFixedFee();
      });
    }
  },

  // needs to be usable by cocoon:after-insert
  // so can bind to one or many elements
  fixedFeeTypeChange: function ($el) {
    var self = this;
    var $els = $el || $('.js-fixed-fee-calculator-fee-type');
    if ($('.calculated-fixed-fee').exists()) {
      $els.change( function() {
        self.calculateUnitPriceFixedFee();
      });
    }
  },

  fixedFeeQuantityChange: function ($el) {
    var self = this;
    var $els = $el || $('.js-fixed-fee-calculator-quantity');
    if ($('.calculated-fixed-fee').exists()) {
      $els.change( function() {
        self.calculateUnitPriceFixedFee();
      });
    }
  },

  populateInput: function(data, context) {
    var $input = $(context).find('input.form-control');
    $input.val(data.toFixed(2));
    $input.change();
  },

  // FIXME: displayFee kept in for example use only as one option is to display the
  // the fee value/unit price. can be got rid off once we know what we are
  // doing.
  // displayFee: function(data, context) {
  //   data = '&pound;' + moj.Helpers.SideBar.addCommas(data.toFixed(2));
  //   var calculate_html = '<div style="color: #2b8cc4; font-weight: bold;"> Calculated to be: ' + data + '<div>';
  //   var original_label = $(context + ' label').text().replace(/ \Calculated to be: .*/g,'');
  //   var new_label = original_label + ' ' + calculate_html;
  //   $(context + ' label').html(new_label);
  // },

  displayError: function(response, context) {
    // only some errors will have a JSON response
    try { console.log(response.responseJSON.errors); } catch(e) {}
    this.clearErrors(context);
    var $label = $(context).find('label');
    var error_html = '<div class="js-calculate-error" style="color: #b10e1e; font-weight: bold;">' + response.responseJSON["message"] + '<div>';
    var new_label = $label.text() + ' ' + error_html;

    $(context).find('.form-group.rate_wrapper').addClass('field_with_errors form-group-error');
    $label.html(new_label);
  },

  clearErrors: function(context) {
    $(context).find('.form-group.rate_wrapper').removeClass('field_with_errors form-group-error');
    $(context).find('.js-calculate-error').remove();
  },

  displayHelp: function(context, show) {
    $help = $(context).closest('.fixed-fee-group').find('.help-wrapper.form-group');
    show ? $help.show() : $help.hide();
  },

  unitPriceAjax: function (data, context) {
    var self = this;
    $.ajax({
      type: 'GET',
      url: '/external_users/claims/' + data.claim_id + '/calculate_unit_price.json',
      data: data,
      dataType: 'json'
    })
    .done(function(response) {
      self.clearErrors(context);
      self.populateInput(response.data.amount, context);
      self.displayHelp(context, true);
    })
    .fail(function(response) {
      self.displayError(response, context);
      self.displayHelp(context, false);
    });
  },

  addFixedFeeData: function(data) {
    data.claim_id = $('#claim-form').data('claimId');
    data.advocate_category = $('input:radio[name="claim[advocate_category]"]:checked').val();

    var fees = data['fees'] = [];
    $('.fixed-fee-group:visible').each(function() {
      fees.push({
        fee_type_id: $(this).find('select.js-fee-type').val(),
        quantity: $(this).find('input.js-fee-quantity').val()
      });
    });
  },

  // Calculates the "unit price" for a given fixed fee,
  // including fixed fee case uplift fee types.
  calculateUnitPriceFixedFee: function () {
    var self = this;
    var data = {};
    self.addFixedFeeData(data);

    $('.js-fixed-fee-calculator-effectee').each(function() {
      data.fee_type_id = $(this).closest('.fixed-fee-group').find('select.js-fee-type').val();
      self.unitPriceAjax(data, this);
    });
  }
};
