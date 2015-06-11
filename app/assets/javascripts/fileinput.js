var moj = moj || {};
moj.Modules.fileUpload = {
  init: function(){
    $('input[type="file"]').each(function(){
      $(this).change(function(){
          moj.Modules.fileUpload.state($(this));
        });
      if($(parent).find('.file-exists')){
        $(this).hide();
        moj.Modules.fileUpload.chooseAlternative($(this));
        }
      }); 
  },
  state: function(that){
    if($(that).val()){
          $(that).addClass('has-file');
          $(that).show();
          $(that).prev('label.button-secondary').remove();
        }
        else{
          $(that).removeClass('has-file');
        }
  },
  chooseAlternative: function(that){
    var message = "<label for='" + $(that).attr('id') +"' class='button-secondary'>Upload an alternative file</label>"
    $(that).before(message);
  }

};