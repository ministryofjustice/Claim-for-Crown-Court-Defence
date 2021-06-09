moj.Modules.Allocation = {
  init: function () {
    // Only work on the allocation page
    if ($('.js-allocation-page').length > 0) {
      $('.fx-autocomplete-wrapper select').is(function (idx, el) {
        moj.Helpers.Autocomplete.new('#' + el.id, {
          showAllValues: true,
          autoselect: false,
          displayMenu: 'overlay'
        })
      })

      $('#allocation-case-worker-id-field-select').attr('aria-label', 'Case worker')

      $('.dt-checkboxes-select-all input').replaceWith('<input type="checkbox" id="select-all-claim"><label for="select-all-claim" class="visually-hidden">Select all claims</label>')
    }
  }
}
