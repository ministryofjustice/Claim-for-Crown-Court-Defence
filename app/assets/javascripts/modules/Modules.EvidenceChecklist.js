moj.Modules.EvidenceChecklist = {
  el: '.fx-lac-1',
  init : function () {
    $(this.el).is(function(idx, el){
      if(!$('.fx-lac-1').find('input:checked').length){
        $('.fx-lac-1').remove();
      }
    });
  }
};
