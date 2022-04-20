moj.Modules.DefendantsCtrl = {
  init: function () {
    this.addCocoonHooks()
  },

  addCocoonHooks: function () {
    let counter = 0

    $('#defendants').on('cocoon:before-insert', function (e, insertedItem) {
      insertedItem.find(':input').each(function () {
        const inputId = $(this).attr('id')
        const newId = (inputId || '').concat('-', counter++)

        $(this).attr('id', newId)
        $(this).siblings('label').attr('for', newId)
      })
    })
  }
}
