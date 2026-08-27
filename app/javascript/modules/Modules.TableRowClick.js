moj.Modules.TableRowClick = {
  init: function () {
    $('.js-checkbox-table').on('click', function (e) {
      const $target = $(e.target)
      if ($target.is(':checkbox, a')) {
        return
      }
      const $tr = $target.closest('tr')
      const $checkbox = $tr.find(':checkbox')

      $checkbox.prop('checked', !$checkbox.is(':checked'))

      e.preventDefault()
    })
  }
}
