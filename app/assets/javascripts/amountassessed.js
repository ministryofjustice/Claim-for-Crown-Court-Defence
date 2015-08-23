var moj = moj || {};
moj.Modules.amountAssessed = {
  init: function(){
    moj.Modules.amountAssessed.state();
    $('#claim_state_for_form').change(function(){
      moj.Modules.amountAssessed.state();
    });
  },
  state: function(){
    var v = $('#claim_state_for_form option:selected').val();
    if (v === 'part_paid' || v === 'paid' ){
      $('#amountAssessed').slideDown('slow');
    }
    else{
      $('#amountAssessed').slideUp('slow');
    }
  }
};
