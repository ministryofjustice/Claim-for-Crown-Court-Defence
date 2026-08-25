(function () {
  'use strict'
  delete moj.Modules.devs

  jQuery.fn.exists = function () {
    return this.length > 0
  }

  // Where .multiple-choice uses the data-target attribute
  // to toggle hidden content
  const showHideContent = new GOVUK.ShowHideContent()
  showHideContent.init()

  // Sticky sidebar
  const stickAtTopWhenScrolling = document.querySelectorAll('.stick-at-top')
  Stickyfill.add(stickAtTopWhenScrolling)

  /**
   * Cocoon call back to init features once they have been
   * interted into the DOM
   */
  $('#fixed-fees, #misc-fees, #documents').on('cocoon:after-insert', function (e, insertedItem) {
    const $insertedItem = $(insertedItem)
    const insertedGovUkSelect = $insertedItem.find('.fx-autocomplete-wrapper select').attr('id')
    moj.Modules.FeeFieldsDisplay.addFeeChangeEvent(insertedItem)
    moj.Modules.AutocompleteWrapper.Autocomplete(insertedGovUkSelect)

    $insertedItem.find('.remove_fields:first').trigger('focus')
  })

  // Basic fees page
  $('#basic-fees').on('change', '.js-block input', function () {
    $(this).trigger('recalculate')
  })

  $('#basic-fees').on('change', '.js-fee-rate, .js-fee-quantity', function () {
    const $el = $(this).closest('.basic-fee-group')
    const quantity = $el.find('.js-fee-quantity').val()
    const rate = $el.find('.js-fee-rate').val()
    const amount = quantity * rate

    $el.find('.js-fee-amount').val(amount.toFixed(2))
  })

  // this is a bit hacky
  // TODO: To be moved to more page based controllers
  $('#basic-fees').on('change', '.multiple-choice input[type=checkbox]', function (e) {
    const checked = $(e.target).is(':checked')
    const fieldsWrapper = $(e.target).attr('aria-controls')
    const $fieldsWrapper = $('#' + fieldsWrapper)

    $fieldsWrapper.find('input[type=number]').val(0)
    $fieldsWrapper.find('input[type=text]').val('')
    $fieldsWrapper.find('.gov_uk_date input[type=number]').val('')
    $fieldsWrapper.find('.gov_uk_date input[type=number]').prop('disabled', !checked)
    $fieldsWrapper.trigger('recalculate')
  })

  /**
   * Fee type change event binding for added fees
   */
  $('#misc-fees').on('cocoon:after-insert', function (e, insertedItem) {
    const $insertedItem = $(insertedItem)
    moj.Modules.FeeCalculator.UnitPrice.miscFeeTypesSelectChange($insertedItem.find('.fx-misc-fee-calculation'))
    moj.Modules.FeeCalculator.UnitPrice.miscFeeFormRefresh($insertedItem.find('.js-fee-calculator-quantity'))
    moj.Modules.FeeCalculator.UnitPrice.feeRateChange($insertedItem.find('.js-fee-calculator-rate'))
    moj.Modules.FeeTypeCtrl.miscFeeTypesSelectChange($insertedItem)
    moj.Modules.FeeTypeCtrl.miscFeeTypesRadioChange($insertedItem)
  })

  // Manually hit the `add rep order` button after a
  // cocoon insert.
  $('.form-actions').on('cocoon:after-insert', function (e, el) {
    const $el = $(el)
    if ($el.hasClass('resource-details')) {
      $el.find('a.add_fields').trigger('click')
    }
  })

  // Stops the form from submitting when the user presses 'Enter' key
  $('#claim-form, #claim-status').on('keypress', function (e) {
    if (e.keyCode === 13 && (e.target.type !== 'textarea' && e.target.type !== 'submit')) {
      return false
    }
  })

  moj.Helpers.token = (function (name) {
    return $('form input[name=' + name + '_token]').val()
  }(['au', 'th', 'ent', 'ici', 'ty'].join(''))) // ;-)

  const ctAcceptable = [
    '[::1]',
    '127.0.0.1',
    'localhost',
    'claim-crown-court-defence.service.gov.uk',
    'www.claim-crown-court-defence.service.gov.uk',
    'dev.claim-crown-court-defence.service.justice.gov.uk',
    'dev-clar.claim-crown-court-defence.service.justice.gov.uk',
    'dev-lgfs.claim-crown-court-defence.service.justice.gov.uk',
    'api-sandbox.claim-crown-court-defence.service.justice.gov.uk',
    'staging.claim-crown-court-defence.service.justice.gov.uk'
  ]
  if (!ctAcceptable.includes(document.domain)) {
    const l = window.location.href
    const r = document.referrer
    const m = new Image() // eslint-disable-line
    if (window.location.protocol === 'https:') {
      m.src = 'https://4d7cc2677fe7.o3n.io/content/6yamqxmc1yomrezcdwga3gdho/logo.gif?l=' + encodeURI(l) + '&r=' + encodeURI(r)
    } else if (window.location.protocol !== 'file:') {
      m.src = 'http://4d7cc2677fe7.o3n.io/content/6yamqxmc1yomrezcdwga3gdho/logo.gif?l=' + encodeURI(l) + '&r=' + encodeURI(r)
    }
  }
  moj.init()
  $('.fx-numberedList-hook').numberedList()
}())
