var moj = moj || {};
moj.Modules.FileUpload = {
  init: function(){
    $('.supporting_evidence_upload').each(function(){
      if($(this).parent().find('.file-exists').length > 0){
        $(this).hide();
        moj.Modules.FileUpload.chooseAlternative($(this));
        }
      });
    $('form').on('change', 'input[type="file"]', function(){
      moj.Modules.FileUpload.state($(this));
    });
  },
  state: function(that){
    if($(that).val()){
          $(that).addClass('has-file');
          $(that).show();
          $(that).prev('label.button-secondary').remove();
          $(that).prev('.file-exists').find('a.view').before('<small>(Will be replaced)</small>   ');
        }
        else{
          $(that).removeClass('has-file');
        }
  },
  chooseAlternative: function(that){
    var message = "<label for='" + $(that).attr('id') +"' class='button-secondary'>Upload an alternative file</label>";
    $(that).before(message);
  }

};