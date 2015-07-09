var moj = moj || {};

moj.Modules.selectAll = {
  init: function() {
    $('.select-all').click(function() {
      var index = $(this).parent().index();

      checkedState = $(this).data('all-checked');
      $(this).data('all-checked', !checkedState);

      $('tr').each(function(i, val) {
        $(val).children().eq(index).children('input[type=checkbox]').prop('checked', !checkedState);
      });

      $(this).text(checkedState ? 'Select all' : 'Select none');

      return false;
    });
  }
};
