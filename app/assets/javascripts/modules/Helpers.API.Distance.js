(function(exports, $) {
  var Module = exports.Helpers.API || {};

  // Default config
  var settings = {

    // This is the ajax config object
    ajax: {
      url: '/establishments.json',
      type: 'GET',
      dataType: 'json'
    },
    // Success / Fail events via $.publish()
    events: {
      cacheLoaded: '/API/expenses/loaded/',
      cacheLoadError: '/API/expenses/load/error/'
    }
  };


  // Query will merge the setttings
  // and delegate to ..API.CORE
  function query(ajaxConfig) {
    var mergedSettings;
    mergedSettings = $.extend(settings.ajax, ajaxConfig);
    return moj.Helpers.API._CORE.query(mergedSettings);
  }

  Module.Distance = {
    query: query
  };

  exports.Helpers.API = Module;
}(moj, jQuery));
