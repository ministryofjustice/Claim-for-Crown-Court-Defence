moj.Modules.FeeCalculator = {
  init: function () {
    this.bindEvents();
  },

  bindEvents: function () {
    this.advocateTypeChange();
    this.feeTypeChange();
    this.feeRateChange();
    this.feeQuantityChange();
    this.pageLoad();
  },

  advocateTypeChange: function () {
    var self = this;
    if ($('.calculated-fee').exists()) {
      $('.js-fixed-fee-calculator-advocate-type').change( function() {
        self.calculateUnitPriceFee();
      });
    }
  },

  // needs to be usable by cocoon:after-insert so can bind to one or many elements
  feeTypeChange: function ($el) {
    var self = this;
    var $els = $el || $('.js-fee-calculator-fee-type');
    if ($('.calculated-fee').exists()) {
      $els.change( function() {
        self.calculateUnitPriceFee();
      });
    }
  },

  // needs to be usable by cocoon:after-insert so can bind to one or many elements
  feeQuantityChange: function ($el) {
    var self = this;
    var $els = $el || $('.js-fee-quantity');
    if ($('.calculated-fee').exists()) {
      $els.change( function() {
        self.calculateUnitPriceFee();
        self.populateNetAmount(this);
      });
    }
  },

  // needs to be usable by cocoon:after-insert so can bind to one or many elements
  feeRateChange: function ($el) {
    var self = this;
    var $els = $el || $('.js-fee-calculator-rate');
    $els.change( function() {
      self.populateNetAmount(this);
    });
  },

  setRate: function(data, context) {
    var $input = $(context).find('input.fee-rate');
    var $calculated = $(context).siblings('.js-fee-calculator-success').find('input');
    $input.val(data.toFixed(2));
    $input.change();
    $calculated.val(data > 0);
    $input.prop('readonly', data > 0);
  },

  setHintLabel: function(data) {
    var $result = '';
    switch(data) {
      case 'HALFDAY':
        $result = 'half day';
        break;
      case 'DEFENDANT':
      case 'CASE':
        $result = 'additional ' + data;
        break;
      default:
        $result = data;
    }

    return  (data ? "Number of " + $result.toLowerCase() + 's' : '');
  },

  setHint: function(data, context) {
    var self = this;
    var $label = $(context).closest('.fx-fee-group').find('.form-group.quantity_wrapper').find('.form-hint');
    var $newLabel = self.setHintLabel(data);
    $label.text($newLabel);
    data ? $label.show() : $label.hide();
  },

  enableRate: function(context) {
    $(context).find('input.fee-rate').prop('readonly', false);
  },

  populateNetAmount: function(context) {
    var $feeGroup = $(context).closest('.fx-fee-group');
    var $el = $feeGroup.find('.fee-net-amount');
    var rate = $feeGroup.find('input.fee-rate').val();
    var quantity = $feeGroup.find('input.fee-quantity').val();
    var value = (rate * quantity);
    var text = '&pound;' + moj.Helpers.Blocks.addCommas(value.toFixed(2));
    $el.html(text);
  },

  displayError: function(response, context) {
    // only some errors will have a JSON response
    this.clearErrors(context);
    var $label = $(context).find('label');
    var $calculated = $(context).closest('.fx-fee-group').find('.js-fee-calculator-success').find('input');
    var error_html = '<div class="js-calculate-error form-hint">' + response.responseJSON["message"] + '<div>';
    var new_label = $label.text() + ' ' + error_html;
    var $input = $(context).find('input.fee-rate');

    $input.val('');
    $input.prop("readonly", false);
    $calculated.val(false);
    $label.html(new_label);
  },

  clearErrors: function(context) {
    $(context).find('.js-calculate-error').remove();
  },

  displayHelp: function(context, show) {
    var $help = $(context).siblings('.help-wrapper.form-group');
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
      self.setRate(response.data.amount, context);
      self.setHint(response.data.unit, context);
      self.displayHelp(context, true);
    })
    .fail(function(response) {
      if (response.responseJSON['errors'][0] != 'incomplete') {
        self.displayError(response, context);
        self.displayHelp(context, false);
        self.setHint(null, context);
      }
      self.enableRate(context);
    });
  },

  buildFeeData: function(data) {
    data.claim_id = $('#claim-form').data('claimId');
    var advocate_category = $('input:radio[name="claim[advocate_category]"]:checked').val();
    if (advocate_category) {
      data.advocate_category = advocate_category
    }
    // TODO: check if this can be here instead of calculateUnitPrice
    // loop iteration for $('.js-fee-calculator-effectee')
    // data.fee_type_id = $(this).closest('.fx-fee-group').find('.js-fee-type').first().val();

    var fees = data.fees = [];
    $('.fx-fee-group:visible').each(function() {
      fees.push({
        fee_type_id: $(this).find('.js-fee-type').first().val(),
        quantity: $(this).find('input.js-fee-quantity').val()
      });
    });
  },

  // Calculates the "unit price" for a given fee,
  // including fixed fee case uplift fee types,
  // and misc fee defendant uplifts.
  calculateUnitPriceFee: function () {
    var self = this;
    var data = {};
    self.buildFeeData(data);

    $('.js-fee-calculator-effectee').each(function () {
      data.fee_type_id = $(this).closest('.fx-fee-group').find('.js-fee-type').first().val();
      self.unitPriceAjax(data, this);
    });
  },

  pageLoad: function () {
    var self = this;
    $(document).ready( function() {
      $('.calculated-fee').each(function() {
        self.calculateUnitPriceFee();
      });
    });
  }
};
