// moj.Modules.FeeCalculator.UnitPrice
(function (exports, $) {
  var Modules = exports.Modules.FeeCalculator || {};

  Modules.UnitPrice = {
    init: function () {
      this.bindEvents();
    },

    bindEvents: function () {
      this.advocateTypeChange();
      this.basicFeeTypeChange();
      this.fixedFeeTypeChange();
      this.miscFeeTypeChange();
      this.feeQuantityChange();
      this.feeRateChange();
      this.pageLoad();
    },

    advocateTypeChange: function () {
      var self = this;
      // TODO: move this to a data-flag
      if ($('.calculated-unit-fee').exists()) {
        $('.js-fee-calculator-advocate-type').change(function () {
          self.calculateUnitPrice();
        });
      }
    },

    // clear the fixed fee
    clearFee: function (el) {
      var $el = $(el);
      $el.find('.quantity').val('');
      $el.find('.rate').val('');
      $el.find('.total').html('£0.00');
    },

    // TODO: this method should not form part of fee calc logic
    // It should be a part of the checkbox logic and located in a module
    // related to that.
    markForDestruction: function (context, bool) {
      $(context + '-input').siblings('.destroy').val(bool);
    },

    feeTypeCheckboxChange: function (elId) {
      var self = this;

      $(elId).on('change', '.fx-checkbox-hook', function (e) {
        var $el = $(e.target);
        var parentEl = '#' + $el.closest('.multiple-choice').data('target');

        if (!$el.is(':checked')) {
          // TODO: if we are going to destroy the fee do we need to clear it?
          self.clearFee(parentEl);
          self.markForDestruction(parentEl, true);
        } else {
          self.markForDestruction(parentEl, false);
        }

        // Always redo calculation because of fee calc interdependencies
        self.calculateUnitPrice();
      });
    },

    basicFeeTypeChange: function () {
      this.feeTypeCheckboxChange('#basic-fees');
    },

    fixedFeeTypeChange: function () {
      this.feeTypeCheckboxChange('#fixed-fees');
    },

    miscFeeTypeCheckboxChange: function () {
      this.feeTypeCheckboxChange('#misc-fees');
    },

    // needs to be usable by cocoon:after-insert so can bind to one or many elements
    miscFeeTypesSelectChange: function ($el) {
      var self = this;
      var $els = $el || $('.fx-misc-fee-calculation');

      if ($('.fx-misc-fee-calculation').exists() && $('.calculated-unit-fee').exists()) {
        $els.change(function () {
          self.calculateUnitPrice();
        });
      }
    },

    // needs to handle both select list and checboxes
    // for advocate final and supplementary claims respectively.
    //
    miscFeeTypeChange: function () {
      this.miscFeeTypesSelectChange();
      this.miscFeeTypeCheckboxChange();
    },

    // needs to be usable by cocoon:after-insert so can bind to one or many elements
    feeQuantityChange: function ($el) {
      var self = this;
      var $els = $el || $('.js-fee-quantity');
      if ($('.calculated-unit-fee').exists()) {
        $els.on('change keyup', $.debounce(290, function (e) {
          self.calculateUnitPrice();
          self.populateNetAmount(this);
        }));
      }
    },

    // needs to be usable by cocoon:after-insert so can bind to one or many elements
    feeRateChange: function ($el) {
      var self = this;
      var $els = $el || $('.js-fee-calculator-rate');
      $els.change(function () {
        self.populateNetAmount(this);
      });
    },

    setRate: function (data, context) {
      var $input = $(context).find('input.fee-rate');
      var $price_calculated = $(context).siblings('.js-fee-calculator-success').find('input');

      $input.val(data.toFixed(2));
      $input.change();
      $price_calculated.val(data > 0);
      $input.prop('readonly', data > 0);
    },

    // TODO: backend should tell front end what to present
    // in data attributes preferably
    setHintLabel: function (data) {
      var $result = '';
      switch (data) {
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

      return (data ? 'Number of ' + $result.toLowerCase() + 's' : '');
    },

    setHint: function (data, context) {

      var self = this;
      var $label = $(context).closest('.fx-fee-group').find('.form-group.quantity_wrapper').find('.form-hint');
      var $newLabel = self.setHintLabel(data);
      $label.text($newLabel);

      data ? $label.show() : $label.hide();
    },

    enableRate: function (context) {
      $(context).find('input.fee-rate').prop('readonly', false);
    },

    populateNetAmount: function (context) {
      var $feeGroup = $(context).closest('.fx-fee-group');
      var $el = $feeGroup.find('.fee-net-amount');
      var rate = $feeGroup.find('input.fee-rate').val();
      var quantity = $feeGroup.find('input.fee-quantity').val();
      var value = (rate * quantity);
      var text = '&pound;' + moj.Helpers.Blocks.addCommas(value.toFixed(2));
      $el.html(text);
    },

    displayError: function (response, context) {
      // only some errors will have a JSON response
      this.clearErrors(context);
      var $label = $(context).find('label');
      var $price_calculated = $(context).find('.js-fee-calculator-success > input');
      var error_html = '<div class="js-calculate-unit-error form-hint">' + response.responseJSON.message + '<div>';
      var new_label = $label.text() + ' ' + error_html;
      var $input = $(context).find('input.fee-rate');

      $input.prop('readonly', false);
      $price_calculated.val(false);
      $label.html(new_label);
    },

    clearErrors: function (context) {
      $(context).find('.js-calculate-unit-error').remove();
    },

    displayHelp: function (context, show) {
      var $help = $(context).closest('.fx-fee-group').find('.fee-calc-help-wrapper');
      show ? $help.removeClass('hidden') : $help.addClass('hidden');
    },

    unitPriceAjax: function (data, context) {
      var self = this;
      var dataobject = {
        type: 'POST',
        url: '/external_users/claims/' + data.claim_id + '/fees/calculate_price.json',
        data: data,
        dataType: 'json'
      };

      $.ajax(dataobject)
        .done(function (response) {
          self.clearErrors(context);
          self.setRate(response.data.amount, context);
          self.setHint(response.data.unit, context);
          self.displayHelp(context, true);
        })
        .fail(function (response) {
          if (response.hasOwnProperty('responseJSON') && response.responseJSON.errors[0] != 'insufficient_data') {
            self.displayError(response, context);
            self.setHint(null, context);
          }

          self.displayHelp(context, false);
          self.enableRate(context);
        });
    },

    buildFeeData: function (data) {
      data.claim_id = $('#claim-form').data('claimId');
      data.price_type = 'UnitPrice';
      var advocate_category = $('input:radio[name="claim[advocate_category]"]:checked').val();
      if (advocate_category) {
        data.advocate_category = advocate_category;
      }

      var fees = data.fees = [];
      $('.fx-fee-group:visible').each(function () {
        fees.push({
          fee_type_id: $(this).find('.js-fee-type').first().val(),
          quantity: $(this).find('input.js-fee-quantity').val()
        });
      });
    },

    // Calculates the "unit price" for a given fee,
    // including fixed fee case uplift fee types,
    // and misc fee defendant uplifts.
    calculateUnitPrice: function () {
      var self = this;
      var data = {};

      this.buildFeeData(data);

      $('.js-unit-price-effectee').each(function (idx, el) {
        if ($(el).is(':visible')) {
          data.fee_type_id = $(this).closest('.fx-fee-group').find('.js-fee-type').first().val();
          self.unitPriceAjax(data, this);
        }
      });

      // if everything is hidden - force sidebar recalculate
      if ($('.js-unit-price-effectee:visible').length === 0) {
        $('#claim-form').trigger('recalculate');
      }
    },

    pageLoad: function () {
      var self = this;
      $(document).ready(function () {
        // TODO: this loop is causing multiple init procedures
        // limiting it for now to at least one visible
        $('.calculated-unit-fee:visible:first').each(function () {
          self.calculateUnitPrice();
        });
      });
    }
  };

  exports.Modules.FeeCalculator = Modules;
}(moj, jQuery));
