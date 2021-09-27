moj.Modules.SelectAll = {
  init: function () {
    $('.select-all').on('click', function () {
      const $element = $(this)
      const checkedState = $element.data('all-checked')

      $element.data('all-checked', !checkedState)

      $('tr').each(function (idx, el) {
        const $el = $(el)
        if ($el.find('input').length) {
          $el.find('input').prop('checked', !checkedState)
        }
      })

      $element.text(checkedState ? 'Select all' : 'Select none')

      return false
    })
  }
}
