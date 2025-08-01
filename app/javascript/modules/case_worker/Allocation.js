moj.Modules.Allocation = {
  init: function () {
    const allocationPage = document.querySelector('.js-allocation-page')

    if (allocationPage) {
      this.replaceDataTableInput()
      this.toggleDataTableSelectionText()
    }
  },

  replaceDataTableInput: function () {
    // change to Web API: replaceWith (https://developer.mozilla.org/en-US/docs/Web/API/Element/replaceWith)
    // once IE usage fall below 2%
    $('.dt-checkboxes-select-all input')
      .replaceWith(
        '<div class="govuk-form-group">' +
        '<div class="govuk-checkboxes govuk-checkboxes--small" data-module="govuk-checkboxes">' +
        '<div class="govuk-checkboxes__item">' +
        '<input class="govuk-checkboxes__input" type="checkbox" name="select-all-claim" id="select-all-claim">' +
        '<label class="govuk-label govuk-checkboxes__label" for="select-all-claim">' +
        '<span class="govuk-visually-hidden">Select all</span>' +
        '</label>' +
        '</div>' +
        '</div>' +
        '</div>'
      )
  },

  toggleDataTableSelectionText: function () {
    const checkBox = document.querySelector('.dt-checkboxes-select-all input')
    const checkBoxLabel = document.querySelector('.dt-checkboxes-select-all label span')

    if (checkBox) {
      checkBox.onclick = function () {
        this.checked ? checkBoxLabel.innerText = 'De-select all' : checkBoxLabel.innerText = 'Select all'
      }
    }
  }
}
