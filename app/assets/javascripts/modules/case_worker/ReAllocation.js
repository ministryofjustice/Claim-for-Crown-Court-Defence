moj.Modules.ReAllocation = {
  $ReAllocationRadioButtons: $('.js-re-allocation-options'),
  $CaseWorkerList: $('.js-case-worker-list'),

  init: function (){
    var self = this;

    //Only work on the re-allocation page
    if($('.js-re-allocation-page').length > 0){

      //Show/Hide Case Workers select lists
      self.showHideCaseWorkersList();

      this.$ReAllocationRadioButtons.on('change', ':radio', function(){
        self.showHideCaseWorkersList();
      });
    }
  },

  showHideCaseWorkersList: function(){
    if(this.$ReAllocationRadioButtons.find(':checked').val() === 'false' ){
      this.$CaseWorkerList.slideDown();
    }else{
      this.$CaseWorkerList.slideUp();
    }
  }
};
