moj.Modules.AutocompleteWrapper = {
  init: function () {
    const list = document.querySelectorAll('.fx-autocomplete-wrapper select')
    if (!list.length) return
    this.initAutocomplete(list)
  },

  initAutocomplete: function (nodeList) {
    for (let i = 0; i < nodeList.length; i++) {
      this.Autocomplete(nodeList[i].id)
    }
  },

  Autocomplete: function (elementId) {
    moj.Helpers.Autocomplete.new('#' + elementId, {
      autoselect: false,
      displayMenu: 'overlay',
      showAllValues: true
    })
  }
}
