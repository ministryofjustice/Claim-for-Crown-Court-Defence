moj.Modules.Providers = {
  init: function() {
    console.log('moj.Modules.Providers');

    // Publish the agfs event when provider changes
    // this will show / hide AGFS supplier number
    $.subscribe('/provider/type/', function(e, obj) {

      $.publish('/scheme/type/agfs/', obj);
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

    $.jqReveal({
      // options go here
    });
  }
};