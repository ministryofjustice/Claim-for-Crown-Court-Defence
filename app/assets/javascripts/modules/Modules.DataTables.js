// Modules.DataTables
//
// All future DataTables instances should have a
// similair relationship as Module.Allocation
//
// Possible refactors include making this Module into a helper
// as a proper Constructor. Currently Modules opperate as Controllers
//
// This pattern works well - but only if there is one DataTable on a page
// with multiple tables on a page - a more OO friendly pattern should be used.
//
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
      [10, 25, 50],
      [10, 25, 50]
    ]
  },
  _init: function(options, el) {
    // Extend defaults with passed in options obj
    var __options = $.extend({}, this._defaultOptions, options || {});
    this.bindPublishers();

    // Init through moj.Helpers.DataTables
    // Abstraction might not be required to this level.
    // Will review with Re-allocation & Claims list
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