// moj.Modules.FeeCalculator.GraduatedPrice
(function(exports, $) {
  var Modules = exports.Modules.FeeCalculator || {};

  Modules.GraduatedPrice = {
    init: function () {
      this.bindEvents();
    },

    bindEvents: function () {
      this.advocateTypeChange();
      this.feeTypeChange();
      this.feeDaysChange();
      this.feePpeChange();
      this.pageLoad();
    },

    advocateTypeChange: function () {
      var self = this;
      if ($('.calculated-grad-fee').exists()) {
        $('.js-fee-calculator-advocate-type').change( function() {
          self.calculateGraduatedPrice();
        });
      }
    },

    feeTypeChange: function ($el) {
      var self = this;
      var $el = $('.js-fee-calculator-fee-type');
      if ($('.calculated-grad-fee').exists()) {
        $el.change( function() {
          self.calculateGraduatedPrice();
        });
      }
    },

    feeDaysChange: function ($el) {
      var self = this;
      var $els = $el || $('.js-fee-calculator-days');
      if ($('.calculated-grad-fee').exists()) {
        $els.on('change keyup', function() {
          self.calculateGraduatedPrice();
        });
      }
    },

    feePpeChange: function ($el) {
      var self = this;
      var $els = $el || $('.js-fee-calculator-ppe');
      if ($('.calculated-grad-fee').exists()) {
        $els.on('change keyup', function() {
          self.calculateGraduatedPrice();
        });
      }
    },

    setAmount: function(data, context) {
      var $amount = $(context).find('input.fee-amount');
      var $price_calculated = $(context).siblings('.js-fee-calculator-success').find('input');

      $amount.val(data.toFixed(2));
      $amount.change();
      $price_calculated.val(data > 0);
      $amount.prop('readonly', data > 0);
    },

    enableAmount: function(context) {
      $(context).find('input.fee-amount').prop('readonly', false);
    },

    displayError: function(response, context) {
      // only some errors will have a JSON response
      this.clearErrors(context);
      var $label = $(context).find('label');
      var $calculated = $(context).closest('.fx-fee-group').find('.js-fee-calculator-success').find('input');
      var error_html = '<div class="js-calculate-error form-hint">' + response.responseJSON["message"] + '<div>';
      var new_label = $label.text() + ' ' + error_html;
      var $input = $(context).find('input.fee-amount');

      $input.val('');
      $input.prop("readonly", false);
      $calculated.val(false);
      $label.html(new_label);
    },

    clearErrors: function(context) {
      $(context).find('.js-calculate-error').remove();
    },

    displayHelp: function(context, show) {
      var $help = $(context).closest('.fx-fee-group').find('.fee-calc-help-wrapper');
      show ? $help.show() : $help.hide();
    },

    graduatedPriceAjax: function (data, context) {
      var self = this;
      $.ajax({
        type: 'POST',
        url: '/external_users/claims/' + data.claim_id + '/fees/calculate_price.json',
        data: data,
        dataType: 'json'
      })
      .done(function(response) {
        self.clearErrors(context);
        self.setAmount(response.data.amount, context);
        self.displayHelp(context, true);
      })
      .fail(function(response) {
        if (response.responseJSON['errors'][0] != 'incomplete') {
          self.displayError(response, context);
        }
        self.displayHelp(context, false);
        self.enableAmount(context);
      });
    },

    buildFeeData: function(data) {
      data.claim_id = $('#claim-form').data('claimId');
      data.price_type = 'GraduatedPrice';
      var advocate_category = $('input:radio[name="claim[advocate_category]"]:checked').val();
      if (advocate_category) {
        data.advocate_category = advocate_category;
      }
      data.fee_type_id = $('.fx-fee-group').find('.js-fee-type').val();
      data.ppe = $('.fx-fee-group').find('input.js-fee-calculator-ppe').val();
      data.days = $('.fx-fee-group').find('input.js-fee-calculator-days:visible').val();
    },

    // Calculates the price for a given graduated fee,
    calculateGraduatedPrice: function () {
      var self = this;
      var data = {};
      self.buildFeeData(data);
      self.graduatedPriceAjax(data, '.js-fee-calculator-effectee');
    },

    pageLoad: function () {
      var self = this;
      $(document).ready( function() {
        $('.calculated-grad-fee').each(function() {
          self.calculateGraduatedPrice(self);
        });
      });
    }
  };

  exports.Modules.FeeCalculator = Modules;
}(moj, jQuery));
