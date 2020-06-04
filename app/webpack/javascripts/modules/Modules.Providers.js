moj.Modules.Providers = {
  init: function() {
    // Publish the agfs event when provider changes
    // this will show / hide AGFS supplier number
    $.subscribe('/provider/type/', function(e, obj) {

      $.publish('/scheme/type/agfs/', obj);
      $.publish('/scheme/type/lgfs/', obj);
    });


    // Subscribe to the AGFS event and publish the full state
    // via a proxy listener
    $.subscribe('/scheme/type/agfs/', function(e, obj) {
      var provider = $('#provider_provider_type_chamber').is(':checked') ? 'chamber' : 'firm';
      var $agfs = $('#provider_roles_agfs').is(':checked');
      $.publish('/scheme/type/agfs/proxy/', {
        provider: provider,
        agfs: $agfs
      });
    });

    // Proxy listener to conditionally show / hide the supplier
    // number for agfs
    $.subscribe('/scheme/type/agfs/proxy/', function(event, obj) {
      if (obj.provider === 'firm' && obj.agfs === true) {
        $.publish('/scheme/type/agfs/custom/', {
          eventValue: 'show-agfs-supplier'
        });
        return;
      }
      $('input#provider_firm_agfs_supplier_number').val('');
      $.publish('/scheme/type/agfs/custom/', {
        eventValue: 'hide-agfs-supplier'
      });
    });

    $.subscribe('/scheme/type/lgfs/', function(e, obj) {
      var provider = $('#provider_provider_type_chamber').is(':checked') ? 'chamber' : 'firm';
      var $lgfs = $('#provider_roles_lgfs').is(':checked');
      $.publish('/scheme/type/lgfs/proxy/', {
        provider: provider,
        lgfs: $lgfs
      });
    });

    // Proxy listener to conditionally show / hide the supplier
    // number for lgfs
    $.subscribe('/scheme/type/lgfs/proxy/', function(event, obj) {
      if (obj.provider === 'firm' && obj.lgfs === true) {
        $.publish('/scheme/type/lgfs/custom/', {
          eventValue: 'show-lgfs-supplier'
        });
        return;
      }
      $('input#provider_firm_lgfs_supplier_number').val('');
      $.publish('/scheme/type/lgfs/custom/', {
        eventValue: 'hide-lgfs-supplier'
      });
    });

    $.jqReveal({
      // options go here
    });
  }
};
