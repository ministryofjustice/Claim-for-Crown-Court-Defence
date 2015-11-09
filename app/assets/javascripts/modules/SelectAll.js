moj.Modules.SelectAll = {
  init: function() {
    $('.select-all').click(function() {
      var $element = $(this);
      var index = $element.parent().index();
      var checkedState = $element.data('all-checked');
      $element.data('all-checked', !checkedState);

      $('tr').each(function(i, val) {
        $(val).children().eq(index).children('input[type=checkbox]').prop('checked', !checkedState);
      });

      $element.text(checkedState ? 'Select all' : 'Select none');

      return false;
    });
  }
};
