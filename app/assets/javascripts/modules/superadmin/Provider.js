moj.Modules.SuperAdminProvider = {
    el: 'provider-form',
    $form: {},
    providerType: 'js-provider-type',
    providerRoles: 'js-provider-roles',
    $providerType: {},
    $providerRoles: {},
    supplierNumber: 'js-supplier-number',
    supplierNumbers: 'js-supplier-numbers',
    $supplierNumber: {},
    vatRegistered: 'js-vat-registered',
    $vatRegistered: {},

    init: function () {
        var self = this;
        self.cacheElems();

        //Check the current state on page load
        self.showHide();

        //Add event listeners
        self.$providerType.on('change', ':radio', function () {
            self.showHide();
        });
        self.$providerRoles.on('change', ':checkbox', function () {
            self.showHide();
        });
    },

    cacheElems: function () {
        this.$form = $('#' + this.el);
        this.$providerType = $('#' + this.providerType);
        this.$providerRoles = $('#' + this.providerRoles);
        this.$supplierNumber = $('#' + this.supplierNumber);
        this.$supplierNumbers = $('#' + this.supplierNumbers);
        this.$vatRegistered = $('#' + this.vatRegistered);
    },

    showHide: function () {
        var providerTypeVal = this.$providerType.find(':radio').filter(':checked').val();
        var selectedRoles = $.map(this.$providerRoles.find(':checkbox').filter(':checked'), function(checkbox) {
            return checkbox.value;
        });

        // Show supplier number and vat registered if the provider is a firm
        if (providerTypeVal === 'firm') {
            this.$vatRegistered.show();
        } else {
            this.$vatRegistered.hide();
        }

        if ($.inArray("agfs", selectedRoles) != -1) {
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
