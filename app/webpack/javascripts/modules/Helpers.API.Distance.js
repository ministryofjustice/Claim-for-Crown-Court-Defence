(function(exports, $) {
  var Module = exports.Helpers.API || {};

  // claimid
  // Default config
  var settings = {

    // This is the ajax config object
    ajax: function(ajaxConfig) {

      if (!ajaxConfig) throw Error('Missing params: `ajaxConfig`');
      if (!ajaxConfig.claimid) throw Error('Missing param: `params.claimid` is required');
      if (!ajaxConfig.destination) throw Error('Missing param: `params.destination` is required');

      // Settings defaults
      var settings = $.extend({claimid: 0, destination: 'London'}, ajaxConfig);
      return {
        url: '/external_users/claims/' + settings.claimid + '/expenses/calculate_distance',
        type: 'POST',
        data: {
          destination: settings.destination
        }
      };
    }
  };

  // Query will merge the setttings
  // and delegate to ..API.CORE
  function query(ajaxConfig) {
    return moj.Helpers.API._CORE.query(settings.ajax(ajaxConfig));
  }

  Module.Distance = {
    query: query
  };

  exports.Helpers.API = Module;
}(moj, jQuery));
