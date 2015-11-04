moj.Modules.AllocationFilterSubmit = {
  init: function() {
    $('.allocation-filter-form input[type="submit"]').hide();
    $('.allocation-filter-form input[type="radio"]').change(function() {
      $('.allocation-filter-form').submit();
    });
  }
};
