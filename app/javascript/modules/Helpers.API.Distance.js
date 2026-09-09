(function (exports, $) {
  const Module = exports.Helpers.API || {}

  // claimid
  // Default config
  const settings = {

    // This is the ajax config object
    ajax: function (ajaxConfig) {
      if (!ajaxConfig) throw Error('Missing params: `ajaxConfig`')
      if (!ajaxConfig.claimid) throw Error('Missing param: `params.claimid` is required')
      if (!ajaxConfig.destination) throw Error('Missing param: `params.destination` is required')

      // Settings defaults
      const ajaxSettings = $.extend({ claimid: 0, destination: 'London' }, ajaxConfig)
      return {
        url: '/external_users/claims/' + ajaxSettings.claimid + '/expenses/calculate_distance',
        type: 'POST',
        data: {
          destination: ajaxSettings.destination
        }
      }
    }
  }

  // Query will merge the setttings
  // and delegate to ..API.CORE
  function query (ajaxConfig) {
    return moj.Helpers.API._CORE.query(settings.ajax(ajaxConfig))
  }

  Module.Distance = {
    query
  }

  exports.Helpers.API = Module
}(moj, jQuery))
