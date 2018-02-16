moj.Modules.SelectAll = {
  init: function() {
    $('.select-all').click(function() {
      var $element = $(this);
      var checkedState = $element.data('all-checked');

      $element.data('all-checked', !checkedState);

      $('tr').each(function(idx, el) {
        var $el = $(el);
        if($el.find('input').length){
          $el.find('input').prop('checked', !checkedState);
        }
      });


      $element.text(checkedState ? 'Select all' : 'Select none');

      return false;
    });
  }
};
