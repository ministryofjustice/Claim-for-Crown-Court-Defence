// TINY PUBSUB
// Great little wrapper to easily do pub/sub

/* jQuery Tiny Pub/Sub - v0.7 - 10/27/2011
 * http://benalman.com/
 * Copyright (c) 2011 "Cowboy" Ben Alman; Licensed MIT, GPL */

(function ($) {
  const o = $({})

  $.subscribe = function () {
    o.on.apply(o, arguments)
  }

  $.unsubscribe = function () {
    o.off.apply(o, arguments)
  }

  $.publish = function () {
    o.trigger.apply(o, arguments)
  }
}(jQuery))

// Trunc polyfil
String.prototype.trunc = String.prototype.trunc || function (n) { // eslint-disable-line
  return (this.length > n) ? this.substr(0, n - 1) + '&hellip;' : this
}

// Simple string interpolation
if (!String.prototype.supplant) {
  String.prototype.supplant = function (o) { // eslint-disable-line
    return this.replace(
      /\{([^{}]*)\}/g,
      function (a, b) {
        const r = o[b]
        return typeof r === 'string' || typeof r === 'number' ? r : a
      }
    )
  }
}

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
    const insertedSelect = $insertedItem.find('select.typeahead')
    const typeaheadWrapper = $insertedItem.find('.js-typeahead')

    moj.Modules.Autocomplete.typeaheadKickoff(insertedSelect)
    moj.Modules.Autocomplete.typeaheadBindEvents(typeaheadWrapper)
    moj.Modules.FeeFieldsDisplay.addFeeChangeEvent(insertedItem)

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
    moj.Modules.FeeCalculator.UnitPrice.feeQuantityChange($insertedItem.find('.js-fee-calculator-quantity'))
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

  moj.init()
  $.numberedList()
}())
