moj.Modules.AutocompleteWrapper = {
  init: function () {
    const list = document.querySelectorAll('.fx-autocomplete-wrapper select')
    if (!list.length) return
    this.Autocomplete(list)
  },

  Autocomplete: function (nodeList) {
    nodeList.forEach((node) => {
      return moj.Helpers.Autocomplete.new('#' + node.id, {
        showAllValues: true,
        autoselect: false,
        displayMenu: 'overlay'
      })
    })
  }
}
