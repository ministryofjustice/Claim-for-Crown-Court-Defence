moj.Modules.ReAllocation = {
  $CheckedClaimIdTemplate: $('<input type="hidden" name="allocation[claim_ids][]">'),
  $form: $('#new_allocation'),
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

      //Selecting claims to be re-allocated functionality
      $('.report').on('change', ':checkbox', function (){
        var $element = $(this);

        if($element.is(':checked')){
          self.addCheckedClaim($element.val());
        }else{
          //TODO investigate why this was needed?
          self.removeUnCheckedClaim($element.val());
        }
      });
    }
  },

  showHideCaseWorkersList: function(){
    if(this.$ReAllocationRadioButtons.find(':checked').val() === 'false' ){
      this.$CaseWorkerList.slideDown();
    }else{
      this.$CaseWorkerList.slideUp();
    }
  },

  addCheckedClaim: function (claim_id){
    var $clonedElement = this.$CheckedClaimIdTemplate.clone();
    var id = 'allocation_claim_ids_' + claim_id;

    $clonedElement
      .attr('id', id)
      .val(claim_id);

    //Add the new element to the form
    this.$form.append($clonedElement);
  },

  removeUnCheckedClaim: function (claim_id){
    var $form = this.$form;

    $form
      .find('#allocation_claim_ids_' + claim_id)
      .remove();
  }

};
