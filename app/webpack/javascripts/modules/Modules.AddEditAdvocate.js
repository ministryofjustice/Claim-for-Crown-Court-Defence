moj.Modules.AddEditAdvocate = {
  el : 'js-advocate-roles',
  $userRole : {},
  chamberAdvocates : 'js-chamber-advocates-only',
  $chamberAdvocates : {},
  advocateCheckbox : 'external_user_roles_advocate',
  $advocateCheckbox : {},

  init : function () {
    var self = this;
    self.cacheElems();

    if(self.$chamberAdvocates.length > 0){
      //Check the current state on page load
      self.showHide();

      //Add event listener
      self.$advocateCheckbox.on('change', function (){
        self.showHide();
      });
    }
  },

  cacheElems : function (){
    this.$userRole = $('.' + this.el);
    this.$chamberAdvocates = $('.' + this.chamberAdvocates);
    this.$advocateCheckbox = $('#' + this.advocateCheckbox);
  },

  showHide : function (){

    //Show supplier number and vat registered if the user is an advocate
    if(this.$advocateCheckbox.is(':checked')){
      this.$chamberAdvocates.show();
    }else{
      this.$chamberAdvocates.hide();
    }
  }
};
