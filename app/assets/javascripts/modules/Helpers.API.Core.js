(function(exports, $) {
  var Module = exports.Helpers.API || {};

  function query(ajaxSettings, callbackSettings) {
    // Creating the promise
    var def = $.Deferred();

    // Merge  `ajaxSettings` with defaults
    ajaxSettings = $.extend({}, {
      type: 'GET',
      dataType: 'json'
    }, ajaxSettings);


    // Merge `callbackSettings` with defaults
    callbackSettings = $.extend({}, {
      success: function(results) {
        def.resolve(results);
      },
      error: function(req, status, err) {
        def.reject(status, err);
      }
    }, callbackSettings);

    // Resolve with an error if `url` is missing
    if (!ajaxSettings.url) {
      def.reject('error', {
        message: 'No URL provided'
      });
    }
    // Hand the call to jQuery
    // if there is a `url`
    $.ajax(ajaxSettings).then(callbackSettings.success, callbackSettings.error);

    // Return the promise
    return def.promise();
  }

  Module._CORE = {
    query: query
  };

  exports.Helpers.API = Module;
}(moj, jQuery));
