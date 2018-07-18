moj.Helpers.API = {};

moj.Helpers.API.Expenses = (function($) {

  var cache = {};

  function getLocationByCategory(category) {
    if (!category) {
      return cache;
    }
    return cache.filter(function(obj) {
      return obj.category.indexOf(category) > -1;
    });

  }

  function init() {
    query().then(function(results) {
      cache = results;
      $.publish('/API/expenses/loaded/');
    });
  }

  function query() {
    var def = $.Deferred();
    $.ajax({
      type: 'GET',
      url: '/establishments.json',
      data: {},
      dataType: 'json',
      success: function(results) {
        def.resolve(results);
      },
      error: function(req, status, err) {
        def.reject(status, err);
      }
    });

    return def.promise();
  }

  // init with jquery
  $(function() {
    if ($('#expenses').data('featureDistance')) {
      init();
    }
  });
  return {
    init: init,
    getLocationByCategory: getLocationByCategory
  };
}(jQuery));
