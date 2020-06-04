moj.Modules.Allocation = {
  init: function () {
    var self = this;

    //Only work on the allocation page
    if ($('.js-allocation-page').length > 0) {

      $('.fx-autocomplete').is(function (idx, el) {
        moj.Helpers.Autocomplete.new('#' + el.id, {
          showAllValues: true,
          autoselect: false,
          displayMenu: 'overlay'
        });
      });

      $('#allocation_case_worker_id-select').attr('aria-label', 'Case worker');

      $('.dt-checkboxes-select-all input').replaceWith('<input type="checkbox" id="select-all-claim"><label for="select-all-claim" class="visually-hidden">Select all claims</label>');
    }
  }
};
