// moj.Modules.FeeCalculator.GraduatedPrice
(function (exports, $) {
  const Modules = exports.Modules.FeeCalculator || {}

  Modules.GraduatedPrice = {
    priceType: 'GraduatedPrice',

    init: function () {
      this.bindEvents()
    },

    bindEvents: function () {
      this.advocateTypeChange()
      this.feeTypeChange()
      this.feeDaysChange()
      this.feePpeChange()
      this.feePwChange()
      this.prosecutionEvidenceChange()
      this.pageLoad()
    },

    advocateTypeChange: function () {
      const self = this
      if ($('.calculated-grad-fee').exists()) {
        $('.js-fee-calculator-advocate-type').on('change', function () {
          self.calculateAllGraduatedPrices()
        })
      }
    },

    prosecutionEvidenceChange: function () {
      const self = this
      if ($('.calculated-grad-fee').exists()) {
        $('.js-fee-calculator-prosecution-evidence').on('change', function () {
          self.calculateAllGraduatedPrices()
        })
      }
    },

    // TODO: not used by cocoon, could remove the parameter - only ever one per page atm
    feeTypeChange: function ($el) {
      const $els = $el || $('.js-fee-calculator-fee-type')
      this.bindCalculateEvents($els, this, 'change')
    },

    feeDaysChange: function ($el) {
      const $els = $el || $('.js-fee-calculator-days')
      this.bindCalculateEvents($els, this, 'keyup')
    },

    feePpeChange: function ($el) {
      const $els = $el || $('.js-fee-calculator-ppe')
      this.bindCalculateEvents($els, this, 'keyup')
    },

    feePwChange: function ($el) {
      const $els = $el || $('.js-fee-calculator-pw')
      this.bindCalculateEvents($els, this, 'keyup')
    },

    bindCalculateEvents: function (els, self, eventType) {
      if ($('.calculated-grad-fee').exists()) {
        els.on(eventType, moj.Modules.Debounce.init(function (e) {
          self.calculateGraduatedPrice(e.currentTarget)
        }, 290))
      }
    },

    claimId: function () {
      return $('#claim-form').data('claimId')
    },

    advocateCategory: function () {
      return this.getVal('input:radio[name="claim[advocate_category]"]:checked')
    },

    feeTypeId: function (context) {
      return this.getVal(context, '.js-fee-type')
    },

    ppe: function (context) {
      return this.getVal(context, 'input.js-fee-calculator-ppe')
    },

    pw: function (context) {
      return this.getVal(context, 'input.js-fee-calculator-pw')
    },

    days: function (context) {
      return this.getVal(context, 'input.js-fee-calculator-days:visible')
    },

    prosecutionEvidence: function () {
      return this.getVal('input:radio[name="claim[prosecution_evidence]"]:checked')
    },

    getVal: function (context, selector) {
      if (selector) {
        return $(context).find(selector).val()
      }
      return $(context).val()
    },

    pagesOfProsecutingEvidence: function () {
      return this.prosecutionEvidence() === 'true' ? 1 : 0
    },

    setAmount: function (data, context) {
      const $amount = $(context).find('input.fee-amount')
      const $priceCalculated = $(context).find('.js-fee-calculator-success > input')

      $amount.val(data.toFixed(2))
      $amount.trigger('change')
      $priceCalculated.val(data > 0)
      $amount.prop('readonly', data > 0)
    },

    enableAmount: function (context) {
      $(context).find('input.fee-amount').prop('readonly', false)
    },

    displayError: function (context, message) {
      this.clearErrors(context)
      const $label = $(context).find('.js-graduated-price-effectee > label')
      const $priceCalculated = $(context).find('.js-fee-calculator-success > input')
      const errorHtml = '<div class="js-calculate-grad-error form-hint">' + message + '<div>'
      const newLabel = $label.text() + ' ' + errorHtml
      const $input = $(context).find('input.fee-amount')

      $input.prop('readonly', false)
      $priceCalculated.val(false)
      $label.html(newLabel)
    },

    clearErrors: function (context) {
      $(context).find('.js-calculate-grad-error').remove()
    },

    displayHelp: function (context, show) {
      const $help = $(context).find('.fee-calc-help-wrapper')
      show ? $help.removeClass('hidden') : $help.addClass('hidden')
    },

    feeData: function (context) {
      const data = {}
      data.claim_id = this.claimId()
      data.price_type = this.priceType
      data.advocate_category = this.advocateCategory()
      data.pages_of_prosecuting_evidence = this.pagesOfProsecutingEvidence()
      data.fee_type_id = this.feeTypeId(context)
      data.days = this.days(context)
      data.ppe = this.ppe(context)
      data.pw = this.pw(context)
      return data
    },

    responseErrored: function (response) {
      return Boolean(
        Object.prototype.hasOwnProperty.call(response, 'responseJSON') &&
        response.responseJSON.errors[0] !== 'insufficient_data'
      )
    },

    graduatedPriceAjax: function (data, context) {
      const self = this
      $.ajax({
        type: 'POST',
        url: '/external_users/claims/' + data.claim_id + '/fees/calculate_price.json',
        data,
        dataType: 'json'
      })
        .done(function (response) {
          self.clearErrors(context)
          self.setAmount(response.data.amount, context)
          self.displayHelp(context, true)
        })
        .fail(function (response) {
          if (self.responseErrored(response)) {
            self.displayError(context, response.responseJSON.message)
          }
          self.displayHelp(context, false)
          self.enableAmount(context)
        })
    },

    calculateGraduatedPrice: function (target) {
      const self = this
      const context = $(target).closest('.fx-fee-group')
      self.graduatedPriceAjax(self.feeData(context), context)
    },

    calculateAllGraduatedPrices: function () {
      const self = this
      $('.js-graduated-price-effectee').each(function () {
        self.calculateGraduatedPrice(this)
      })
    },

    pageLoad: function () {
      const self = this
      $(function () {
        $('.calculated-grad-fee').each(function () {
          self.calculateAllGraduatedPrices(self)
        })
      })
    }
  }

  exports.Modules.FeeCalculator = Modules
}(moj, jQuery))
