var moj = moj || {};

moj.Modules.SelectAll = {
  init: function() {
    $('.select-all').click(function() {
      var $element = $(this),
      index = $element.parent().index(),
      checkedState = $element.data('all-checked');
      $element.data('all-checked', !checkedState);

      $('tr').each(function(i, val) {
        $(val).children().eq(index).children('input[type=checkbox]').prop('checked', !checkedState);
      });

      $element.text(checkedState ? 'Select all' : 'Select none');

      return false;
    });
  }
};
