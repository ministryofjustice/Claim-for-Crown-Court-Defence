moj.Modules.TableRowClick = {
  init: function() {
    $('.js-checkbox-table').on('click', function(e) {
      var $target = $(e.target);
      if($target.is(':checkbox, a')) {
        return;
      }
      var $tr = $target.closest('tr');
      var $checkbox = $tr.find(':checkbox');

      $checkbox.prop('checked', !$checkbox.is(':checked'));

      e.preventDefault();
    });
  }
};
