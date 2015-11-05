moj.Modules.AllocationFilterSubmit = {
  init: function() {
    $('.allocation-filter-form')
      .on('change', '[type="radio"]', function() {
        $(this).closest('form').submit();
      })
      .find('input[type="submit"]').hide();
  }
};
