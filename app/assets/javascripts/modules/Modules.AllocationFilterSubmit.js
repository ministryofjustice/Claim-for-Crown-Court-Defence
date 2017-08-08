moj.Modules.AllocationFilterSubmit = {
  init: function() {
    $('.allocation-filter-form')
      .on('change', ':radio', function() {
        $(this).closest('form').submit();
      });
  }
};
