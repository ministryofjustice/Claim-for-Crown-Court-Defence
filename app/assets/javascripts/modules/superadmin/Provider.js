moj.Modules.SuperAdminProvider = {
  el : 'provider-form',
  $form : {},
  providerType : 'js-provider-type',
  $providerType : {},
  supplierNumber : 'js-supplier-number',
  supplierNumbers : 'js-supplier-numbers',
  $supplierNumber : {},
  vatRegistered : 'js-vat-registered',
  $vatRegistered : {},

  init : function () {
    var self = this;
    self.cacheElems();

    //Check the current state on page load
    self.showHide(self.$providerType.find(':radio').filter(':checked').val());

    //Add event listener
    self.$providerType.on('change', ':radio', function (){
      self.showHide(this.value);
    });
  },

  cacheElems : function () {
    this.$form = $('#' + this.el);
    this.$providerType = $('#' + this.providerType);
    this.$supplierNumber = $('#' + this.supplierNumber);
    this.$supplierNumbers = $('#' + this.supplierNumbers);
    this.$vatRegistered = $('#' + this.vatRegistered);
  },

  showHide : function(providerTypeVal){
    //Show supplier number and vat registered if the provider is a firm
    if(providerTypeVal === 'firm'){
      this.$supplierNumber.show();
      this.$supplierNumbers.show();
      this.$vatRegistered.show();
    }else if(providerTypeVal === 'chamber'){
      this.$supplierNumber.hide();
      this.$supplierNumbers.hide();
      this.$vatRegistered.hide();
    }
  }
};
