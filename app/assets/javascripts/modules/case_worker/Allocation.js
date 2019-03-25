moj.Modules.Allocation = {
  $AllocationRadioButtons: $('.js-allocation-options'),
  $CaseWorkerList: $('.js-case-worker-list'),

  init: function() {
    var self = this;

    //Only work on the allocation page
    if ($('.js-allocation-page').length > 0) {

      $('.fx-autocomplete').is(function(idx, el) {
        moj.Helpers.Autocomplete.new('#' + el.id, {
          showAllValues: true,
          autoselect: false,
          displayMenu: 'overlay'
        });
      });
    }
  }
};
