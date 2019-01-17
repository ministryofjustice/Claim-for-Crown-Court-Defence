// moj.Modules.FeeCalculator.GraduatedPrice
(function(exports, $) {
  var Modules = exports.Modules.FeeCalculator || {};

  Modules.GraduatedPrice = {
    priceType: 'GraduatedPrice',

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
        $('.js-fee-calculator-advocate-type').change(function() {
          self.calculateGraduatedPrice();
        });
      }
    },

    // TODO: not used by cocoon, could remove the parameter - only ever one per page atm
    feeTypeChange: function ($el) {
      var self = this;
      var $els = $el || $('.js-fee-calculator-fee-type');
      if ($('.calculated-grad-fee').exists()) {
        $els.change( function() {
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

    claimId: function() {
      return $('#claim-form').data('claimId');
    },

    advocateCategory: function() {
      return $('input:radio[name="claim[advocate_category]"]:checked').val();
    },

    feeTypeId: function() {
      return $('.fx-fee-group').find('.js-fee-type').val();
    },

    ppe: function() {
      return $('.fx-fee-group').find('input.js-fee-calculator-ppe').val();
    },

    days: function() {
      return $('.fx-fee-group').find('input.js-fee-calculator-days:visible').val();
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
      var error_html = '<div class="js-calculate-error form-hint">' + response.responseJSON.message + '<div>';
      var new_label = $label.text() + ' ' + error_html;
      var $input = $(context).find('input.fee-amount');

      $input.val('');
      $input.prop('readonly', false);
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

    feeData: function() {
      var data = {};
      data.claim_id = this.claimId();
      data.price_type = this.priceType;
      data.advocate_category = this.advocateCategory();
      data.fee_type_id = this.feeTypeId();
      data.ppe = this.ppe();
      data.days = this.days();
      return data;
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
        if (response.responseJSON.errors[0] != 'incomplete') {
          self.displayError(response, context);
        }
        self.displayHelp(context, false);
        self.enableAmount(context);
      });
    },

    // Calculates the price for a given graduated fee,
    calculateGraduatedPrice: function () {
      var self = this;
      self.graduatedPriceAjax(self.feeData(), '.js-fee-calculator-effectee');
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
