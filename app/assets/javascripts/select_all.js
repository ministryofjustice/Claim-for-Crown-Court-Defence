var moj = moj || {};

moj.Modules.selectAll = {
  init: function() {
    $('.select-all').click(function() {
      var index = $(this).parent().index();

      $('tr').each(function(i, val){
        $(val).children().eq(index).children('input[type=checkbox]').prop('checked', true);
      });

      return false;
    });
  }
};
