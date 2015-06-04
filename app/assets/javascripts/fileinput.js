var moj = moj || {};
moj.Modules.fileUpload = {
  init: function(){
    $('input[type="file"]').each(function(){
      $(this).change(function(){
          moj.Modules.fileUpload.state($(this));
        });
      moj.Modules.fileUpload.state($(this));
      }); 
  },
  state: function(that){
    if($(that).val()){
          $(that).addClass('has-file');
        }
        else{
          $(that).removeClass('has-file');
        }
  }
};