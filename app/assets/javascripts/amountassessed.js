var moj = moj || {};
moj.Modules.amountAssesed = {
  init: function(){
    moj.Modules.amountAssesed.state();
    $('#claim-status input').change(function(){
      moj.Modules.amountAssesed.state();
    });
  },
  state: function(){
    var v = $('#claim-status input:checked').val();
    if (v == 'part_paid' || v == 'paid' ){
      $('#amountAssessed').slideDown('slow');
    }
    else{
      $('#amountAssessed').slideUp('slow');
    }
  }
};