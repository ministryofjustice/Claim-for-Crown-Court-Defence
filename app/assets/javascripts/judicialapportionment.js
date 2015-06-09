var moj = moj || {};
moj.Modules.judicialApportionment = {
  init: function(){
    moj.Modules.judicialApportionment.state();
    $('#claim_defendants_attributes_0_order_for_judicial_apportionment').change(function(){
      moj.Modules.judicialApportionment.state();
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