moj.Modules.ReAllocation = {
  $ReAllocationRadioButtons: $('.js-re-allocation-options'),
  $CaseWorkerList: $('.js-case-worker-list'),

  init: function() {
    var self = this;

    //Only work on the re-allocation page
    if ($('.js-re-allocation-page').length > 0) {

      //Show/Hide Case Workers select lists
      self.showHideCaseWorkersList();

      this.$ReAllocationRadioButtons.on('change', ':radio', function() {
        self.showHideCaseWorkersList();
      });

      $('.fx-autocomplete').is(function(idx, el) {
        moj.Helpers.Autocomplete.new('#' + el.id, {
          showAllValues: true,
          autoselect: false,
          displayMenu: 'overlay'
        });
      });
    }
  },

  showHideCaseWorkersList: function() {
    if (this.$ReAllocationRadioButtons.find(':checked').val() === 'false') {
      this.$CaseWorkerList.show();
    } else {
      this.$CaseWorkerList.hide();
    }
  }
};
