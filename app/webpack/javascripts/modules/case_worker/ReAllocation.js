moj.Modules.ReAllocation = {
  init: function () {
    const reAllocationPage = document.querySelector('.js-re-allocation-page')

    if (reAllocationPage) {
      this.caseWorkerAutoComplete()
    }
  },

  caseWorkerAutoComplete: function () {
    return moj.Helpers.Autocomplete.new('.fx-autocomplete-wrapper select', {
      showAllValues: true,
      autoselect: false,
      displayMenu: 'overlay'
    })
  }
}
