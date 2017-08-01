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
  _init: function(options, el) {
    var __options = $.extend({}, this._defaultOptions, options || {});
    this.bindPublishers();

    return moj.Helpers.DataTables.init(__options, el);
  },
  bindPublishers: function() {

    // bind a publisher to clear filters
    $('.clear-filters').on('click', function(e) {
      e.preventDefault();
      $.publish('/general/clear-filters/');
    });
  }
}

// init the jquery plugin
// to broadcast events from the filters
$(function() {
  $('.dtFilter').dtFilter();
});