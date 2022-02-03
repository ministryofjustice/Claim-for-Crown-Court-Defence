moj.Modules.AutocompleteWrapper = {
  init: function () {
    const list = document.querySelectorAll('.fx-autocomplete-wrapper select')
    if (!list.length) return
    this.Autocomplete(list)
  },

  Autocomplete: function (nodeList) {
    for (let i = 0; i < nodeList.length; i++) {
      const node = nodeList[i]
      moj.Helpers.Autocomplete.new('#' + node.id, {
        showAllValues: true,
        autoselect: false,
        displayMenu: 'overlay'
      })
    }
  }
}
