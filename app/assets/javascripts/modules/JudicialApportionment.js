moj.Modules.JudicialApportionment = {
  reminder: 'Remember: You must attach the Order for judicial apportionment in the Supporting evidence documents section',
  init: function(){
    $('#claim-form').on('click', 'input[id$="judicial_apportionment"]', function(){
      var whut = $(this).attr('id');
      moj.Modules.JudicialApportionment.state(whut);
    });
  },
  state: function(whut){
    if ($('#' + whut).is(':checked')){
      // show reminder
      $('#' + whut).parent('label').append('<span class="reminder">' + moj.Modules.JudicialApportionment.reminder +'</span>');
    }
    else{
      // hide reminder
      $('#' + whut).parent('label').find('.reminder').remove();
    }
  }
};
