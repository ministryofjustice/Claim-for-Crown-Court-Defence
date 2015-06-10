var moj = moj || {};
moj.Modules.judicialApportionment = {
  reminder: 'Remember: You must attach the Order for judicial apportionment in the Supporting evidence documents section',
  init: function(){
    moj.Modules.judicialApportionment.state();
    $('input[id$="judicial_apportionment"]').change(function(){
      moj.Modules.judicialApportionment.state();
    });
  },
  state: function(){
    if ($('input[id$="judicial_apportionment"]').is(':checked')){
      // show reminder
      $('input[id$="judicial_apportionment"]').parent('label').append('<span class="reminder">' + moj.Modules.judicialApportionment.reminder +'</span>')
    }
    else{
      // hide reminder
      $('input[id$="judicial_apportionment"]').parent('label').find('.reminder').remove();
    }
  }
};