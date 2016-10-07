moj.Modules.SuperAdminProvider = {
  el: 'provider-form',
  $form: {},
  providerType: 'js-provider-type',
  providerRoles: 'js-provider-roles',
  $providerType: {},
  $providerRoles: {},
  firmAgfsSupplierNumber: 'input#provider_firm_agfs_supplier_number',
  supplierNumber: 'js-supplier-number',
  supplierNumbers: 'js-supplier-numbers',
  $supplierNumber: {},
  vatRegistered: 'js-vat-registered',
  $vatRegistered: {},

  init: function() {
    var self = this;
    self.cacheElems();

    //Check the current state on page load
    self.showHide();

    //Add event listeners
    self.$providerType.on('change', ':radio', function(e) {
      self.showHideRoles(e);
      self.showHide();
    });
    self.$providerRoles.on('change', ':checkbox', function(e) {
      if ($(e.target).val() === 'agfs') {
        self.$firmAgfsSupplierNumber.val('');
      }
      self.showHide();
    });
    console.log('end of init');
  },

  cacheElems: function() {
    this.$form = $('#' + this.el);
    this.$providerType = $('#' + this.providerType);
    this.$providerRoles = $('#' + this.providerRoles);
    this.$firmAgfsSupplierNumber = $(this.firmAgfsSupplierNumber);
    this.$supplierNumber = $('#' + this.supplierNumber);
    this.$supplierNumbers = $('#' + this.supplierNumbers);
    this.$vatRegistered = $('#' + this.vatRegistered);
  },

  showHideRoles: function(e) {
    var $el = $(e.target);
    this.$providerRoles.show();
    if ($el.val() == 'chamber') {
      return this.setRoles(0);
    }
    return this.setRoles(1);
  },

  setRoles: function(role) {
    var $lgfs = $('#provider_roles_lgfs');
    var $agfs = $('#provider_roles_agfs');

    if (role === 0) {
      $agfs.attr('checked', true).parent().addClass('focus selected').change();
      $lgfs.attr('checked', false).parent().hide();
    }

    if (role === 1) {
      $agfs.attr('checked', false).attr('disabled', false).parent().removeClass('focus selected').change();
      $lgfs.attr('checked', false).attr('disabled', false).parent().removeClass('focus selected').show();
    }
  },

  showHide: function() {
    var $lgfs = $('#provider_roles_lgfs');
    var providerTypeVal = this.$providerType.find(':radio').filter(':checked').val();
    var selectedRoles = $.map(this.$providerRoles.find(':checkbox').filter(':checked'), function(checkbox) {
      return checkbox.value;
    });

    // Show supplier number and vat registered if the provider is a firm
    if (providerTypeVal === 'firm') {
      $lgfs.prop('disabled', 'disabled');
      $lgfs.prop('checked', 'checked');
      $lgfs.parent().addClass('selected');
      this.$vatRegistered.show();
      this.$providerRoles.show();
    } else {
      this.$vatRegistered.hide();
    }

    if (($.inArray("agfs", selectedRoles) != -1) && providerTypeVal == 'firm') {
      this.$supplierNumber.show();
    } else {
      this.$supplierNumber.hide();
    }

    if ($.inArray("lgfs", selectedRoles) != -1) {
      this.$supplierNumbers.show();
    } else {
      this.$supplierNumbers.hide();
    }
  }
};