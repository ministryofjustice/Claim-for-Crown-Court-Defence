(function (exports, $) {
  const Module = exports.Helpers.API || {}

  // Internal cache
  let internalCache = {}

  let formControls

  // Default config
  const settings = {

    // This is the ajax config object
    ajax: {
      url: '/establishments.json',
      type: 'GET',
      dataType: 'json'
    },
    // The init requires 2 values to be set on a page:
    // $(init.selector).data(init.dataAttr)
    //
    init: {
      // Context selector to obtain the feature flag value
      selector: '#expenses',
      // This attr should contain: true | false
      dataAttr: 'featureDistance'
    },

    // Success / Fail events via $.publish()
    events: {
      cacheLoaded: '/API/establishments/loaded/',
      cacheLoadError: '/API/establishments/load/error/'
    }
  }

  // Init
  function loadData (ajaxConfig) {
    // This module is a simple cache of data
    // It will self init and publish success and failure
    // events when the promise resolves
    return query(ajaxConfig).then(function (results) {
      // Load the results into the internal cache
      internalCache = results.sort(function (a, b) {
        const nameA = a.name.toUpperCase() // ignore upper and lowercase
        const nameB = b.name.toUpperCase() // ignore upper and lowercase
        if (nameA < nameB) {
          return -1
        }
        if (nameA > nameB) {
          return 1
        }
        return 0
      })

      // Publish the success event
      $.publish(settings.events.cacheLoaded)
    }, function (status, error) {
      // Load the error status and response
      // in the the internal cache
      internalCache = {
        error,
        status
      }

      // Publish the success settings.events.cacheLoadError
      $.publish(settings.events.cacheLoadError, internalCache)
    })
  }

  // Query will merge the settings
  // and delegate to ..API.CORE
  function query (ajaxConfig) {
    const mergedSettings = $.extend(settings.ajax, ajaxConfig)
    return moj.Helpers.API._CORE.query(mergedSettings)
  }

  // Filter by category
  function getLocationByCategory (category) {
    // If no catebory return the entire internalCache
    if (!category) {
      return internalCache
    }

    // Filter the internalCache on category
    // Examples: 'crown_court', 'prison', etc
    return internalCache.filter(function (obj) {
      return obj.category.indexOf(category) > -1
    })
  }

  // init with jquery based on a dom selector
  function init () {
    // Checking DOM for feature flag value
    if ($(settings.init.selector).data(settings.init.dataAttr)) {
      formControls = moj.Helpers.FormControls
      return loadData()
    }
  }

  // leaving in place for possible refactor
  function getAsSelectWithOptions (a, b) {
    return getAsOptions(a, b)
  }

  // This method will return an array of <option> tags
  // It is also wrapped in a promise to ensure
  // the entire operation completes before other
  // events are triggered
  function getAsOptions (category, selected) {
    const results = getLocationByCategory(category)
    if (results.length === 0) throw Error('Missing results: no data to build options with')
    const def = $.Deferred()
    formControls.getOptions(results, selected).then(function (els) {
      def.resolve(els)
    }, function () {
      def.reject(arguments)
    })
    return def.promise()
  }

  Module.Establishments = {
    init,
    loadData,
    getLocationByCategory,
    getAsOptions,
    getAsSelectWithOptions
  }

  $(init)

  exports.Helpers.API = Module
}(moj, jQuery))
