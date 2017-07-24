moj.Modules.DataTables = {
  // These options will override the defaults
  _defaultOptions: {
    dom: '<"wrapper"flipt>',
    pagingType: "simple_numbers",
    pageLength: 10,
    order: [
      [0, 'asc']
    ],
    lengthMenu: [
      [10, 25, 50, -1],
      [10, 25, 50, "All"]
    ]
  },
  init: function(options, el) {
    var __options = $.extend({}, this._defaultOptions, options || {});
    return moj.Helpers.DataTables.init(__options, el);
  }
}


$(function() {
  $('.dtFilter').dtFilter();
});