moj.Modules.ReAllocation = {
  $CheckedClaimIdTemplate: $('<input type="hidden" name="allocation[claim_ids][]">'),
  $form: $('#new_allocation'),

  init: function (){
    var self = this;

    $('.report').on('change', ':checkbox', function (){
      var $element = $(this);

      if($element.is(':checked')){
        self.addCheckedClaim($element.val());
      }else{
        self.removeUnCheckedClaim($element.val());
      }
    });
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
