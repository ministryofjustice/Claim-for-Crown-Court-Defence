// moj.Modules.FeeCalculator.UnitPrice
(function (exports, $) {
  const Modules = exports.Modules.FeeCalculator || {}

  Modules.UnitPrice = {
    init: function () {
      this.bindEvents()
    },

    bindEvents: function () {
      this.advocateTypeChange()
      this.basicFeeTypeChange()
      this.fixedFeeTypeChange()
      this.miscFeeTypeChange()
      this.feeQuantityChange()
      this.miscFeeFormRefresh()
      this.feeRateChange()
      this.pageLoad()
    },

    advocateTypeChange: function () {
      const self = this
      // TODO: move this to a data-flag
      if ($('.calculated-unit-fee').exists()) {
        $('.js-fee-calculator-advocate-type').on('change', function () {
          self.calculateUnitPrice()
        })
      }
    },

    // clear the fixed fee
    clearFee: function (el) {
      const $el = $('[data-target=' + el + ']')
      $el.find('.quantity').val('')
      $el.find('.rate').val('')
      $el.find('.total').html('£0.00')
    },

    // TODO: this method should not form part of fee calc logic
    // It should be a part of the checkbox logic and located in a module
    // related to that.
    markForDestruction: function (context, bool) {
      $('[data-target=' + context + ']').children('.destroy').val(bool)
    },

    feeTypeCheckboxChange: function (elId) {
      const self = this

      $(elId).on('change', '.fx-checkbox-hook', function (e) {
        const $el = $(e.target)
        const parentEl = $el.closest("div[class*='fx-hook-']").data('target')

        if (!$el.is(':checked')) {
          // TODO: if we are going to destroy the fee do we need to clear it?
          self.clearFee(parentEl)
          self.markForDestruction(parentEl, true)
        } else {
          self.markForDestruction(parentEl, false)
        }

        // Always redo calculation because of fee calc interdependencies
        self.calculateUnitPrice()
      })
    },

    basicFeeTypeChange: function () {
      this.feeTypeCheckboxChange('#basic-fees')
    },

    fixedFeeTypeChange: function () {
      this.feeTypeCheckboxChange('#fixed-fees')
    },

    miscFeeTypeCheckboxChange: function () {
      this.feeTypeCheckboxChange('#misc-fees')
    },

    // needs to be usable by cocoon:after-insert so can bind to one or many elements
    miscFeeTypesSelectChange: function ($el) {
      const self = this
      const $els = $el || $('.fx-misc-fee-calculation')

      if ($('.fx-misc-fee-calculation').exists() && $('.calculated-unit-fee').exists()) {
        $els.on('change', function () {
          self.calculateUnitPrice()
        })
      }
    },

    // needs to handle both select list and checboxes
    // for advocate final and supplementary claims respectively.
    //
    miscFeeTypeChange: function () {
      this.miscFeeTypesSelectChange()
      this.miscFeeTypeCheckboxChange()
    },

    // needs to be usable by cocoon:after-insert so can bind to one or many elements
    feeQuantityChange: function ($el) {
      const self = this
      const $els = $el || $('.js-fee-quantity')

      if ($('.calculated-unit-fee').exists()) {
        $els.on('change keyup', moj.Modules.Debounce.init(function (e) {
          self.calculateUnitPrice()
          self.populateNetAmount(this)
        }, 290))
      }
    },

    miscFeeFormRefresh: function ($el) {
      const self = this
      const $els = $el || $('#misc-fees')

      if ($('.calculated-unit-fee').exists()) {
        $els.on('click keyup', moj.Modules.Debounce.init(function (e) {
          self.calculateUnitPrice()
          self.populateNetAmount(this)
        }, 290))
      }
    },

    // needs to be usable by cocoon:after-insert so can bind to one or many elements
    feeRateChange: function ($el) {
      const self = this
      const $els = $el || $('.js-fee-calculator-rate')
      $els.on('change', function () {
        self.populateNetAmount(this)
      })
    },

    setRate: function (data, context) {
      const $input = $(context).find('input.fee-rate')
      const $priceCalculated = $(context).siblings('.js-fee-calculator-success').find('input')

      $input.val(data.toFixed(2))
      $input.trigger('change')
      $priceCalculated.val(data > 0)
      $input.prop('readonly', data > 0)
    },

    // TODO: backend should tell front end what to present
    // in data attributes preferably
    setHintLabel: function (data) {
      let $result = ''
      switch (data) {
        case 'HALFDAY':
          $result = 'half day'
          break
        case 'DEFENDANT':
        case 'CASE':
          $result = 'additional ' + data
          break
        case 'FIXED':
          $result = 'fee'
          break
        default:
          $result = data
      }

      return (data ? 'Number of ' + $result.toLowerCase() + 's' : '')
    },

    setHint: function (data, context) {
      const self = this
      const $label = $(context).closest('.fx-fee-group').find('.quantity_wrapper').find('.govuk-hint')
      const $newLabel = self.setHintLabel(data)
      $label.text($newLabel)

      data ? $label.show() : $label.hide()
    },

    enableRate: function (context) {
      $(context).find('input.fee-rate').prop('readonly', false)
    },

    populateNetAmount: function (context) {
      const $feeGroup = $(context).closest('.fx-fee-group')
      const $el = $feeGroup.find('.fee-net-amount')
      const rate = $feeGroup.find('input.fee-rate').val()
      const quantity = $feeGroup.find('input.fee-quantity').val()
      const value = (rate * quantity)
      const text = moj.Helpers.Blocks.formatNumber(value)
      $el.html(text)
    },

    displayError: function (response, context) {
      // only some errors will have a JSON response
      this.clearErrors(context)
      const $label = $(context).find('label')
      const $priceCalculated = $(context).find('.js-fee-calculator-success > input')
      const errorHtml = '<div class="js-calculate-unit-error form-hint">' + response.responseJSON.message + '<div>'
      const newLabel = $label.text() + ' ' + errorHtml
      const $input = $(context).find('input.fee-rate')

      $input.prop('readonly', false)
      $priceCalculated.val(false)
      $label.html(newLabel)
    },

    clearErrors: function (context) {
      $(context).find('.js-calculate-unit-error').remove()
    },

    displayHelp: function (context, show) {
      const $help = $(context).closest('.fx-fee-group').find('.fee-calc-help-wrapper')
      show ? $help.removeClass('hidden') : $help.addClass('hidden')
    },

    unitPriceAjax: function (data, context) {
      const self = this
      const dataobject = {
        type: 'POST',
        url: '/external_users/claims/' + data.claim_id + '/fees/calculate_price.json',
        data,
        dataType: 'json'
      }

      $.ajax(dataobject)
        .done(function (response) {
          self.clearErrors(context)
          self.setRate(response.data.amount, context)
          self.setHint(response.data.unit, context)
          self.displayHelp(context, true)
        })
        .fail(function (response) {
          if (Object.prototype.hasOwnProperty.call(response, 'responseJSON') && response.responseJSON.errors[0] !== 'insufficient_data') {
            self.displayError(response, context)
            self.setHint(null, context)
          }

          self.displayHelp(context, false)
          self.enableRate(context)
        })
    },

    buildFeeData: function (data) {
      data.claim_id = $('#claim-form').data('claimId')
      data.price_type = 'UnitPrice'
      const advocateCategory = $('input:radio[name="claim[advocate_category]"]:checked').val()
      if (advocateCategory) {
        data.advocate_category = advocateCategory
      }

      const fees = data.fees = []
      $('.fx-fee-group:visible').each(function () {
        fees.push({
          fee_type_id: $(this).find('.js-fee-type').first().val(),
          quantity: $(this).find('input.js-fee-quantity').val()
        })
      })
    },

    // Calculates the "unit price" for a given fee,
    // including fixed fee case uplift fee types,
    // and misc fee defendant uplifts.
    calculateUnitPrice: function () {
      const self = this
      const data = {}

      this.buildFeeData(data)

      $('.js-unit-price-effectee').each(function (idx, el) {
        if ($(el).is(':visible')) {
          data.fee_type_id = $(this).closest('.fx-fee-group').find('.js-fee-type').first().val()
          self.unitPriceAjax(data, this)
        }
      })

      // if everything is hidden - force sidebar recalculate
      if ($('.js-unit-price-effectee:visible').length === 0) {
        $('#claim-form').trigger('recalculate')
      }
    },

    pageLoad: function () {
      const self = this
      $(function () {
        // TODO: this loop is causing multiple init procedures
        // limiting it for now to, at most, one visible
        $('.calculated-unit-fee:visible:first').each(function () {
          self.calculateUnitPrice()
        })
      })
    }
  }

  exports.Modules.FeeCalculator = Modules
}(moj, jQuery))
