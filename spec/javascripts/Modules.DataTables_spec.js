describe("Modules.DataTables.js", function() {
  // tooooo long to type
  var defaults = moj.Modules.DataTables._defaultOptions;

  it('...should exist', function() {
    expect(moj.Modules.DataTables).toBeDefined();
  });

  it('...should have defaults set', function() {
    // dom:
    // defines the semantic structure of the table
    //
    // https://datatables.net/reference/option/dom
    expect(defaults.dom).toEqual('<"wrapper"flipt>');

    // pagingType:
    // 6 available settings, current:
    //    full_numbers:   First,
    //                    Previous,
    //                    Next,
    //                    Last,
    //                    plus page numbers
    //
    // https://datatables.net/reference/option/pagingType
    expect(defaults.pagingType).toEqual('simple_numbers');

    // pageLength:
    // Set the initial page length, current: 10
    //
    // https://datatables.net/reference/option/pageLength
    expect(defaults.pageLength).toEqual(10);

    // lengthMenu:
    // Page length option for dropdown
    //
    // https://datatables.net/reference/option/lengthMenu
    expect(defaults.lengthMenu).toEqual([
      [10, 25, 50],
      [10, 25, 50]
    ]);

    // order:
    // 2D array structure. [[col idx, direction]]
    //
    // https://datatables.net/reference/option/order
    expect(defaults.order).toEqual([
      [0, 'asc']
    ]);
  });

  describe('..._init', function() {
    // an init method on these namespaced modules, is called
    // by the parent moj wrapper
    it('...should not have a `init` method', function(){
      expect(moj.Modules.DataTables.init).not.toBeDefined();
    });

    it('...should merge options with defaults and call `moj.Helpers.DataTables.init`', function() {
      // Spy on the final call
      spyOn(moj.Helpers.DataTables, 'init');

      // Setup some simple defaults
      moj.Modules.DataTables._defaultOptions = {
        foo: 'bar'
      };

      // Call the init passinf in options
      moj.Modules.DataTables._init({
        bar: 'foo'
      }, 'element');


      expect(moj.Helpers.DataTables.init).toHaveBeenCalledWith({
        foo: 'bar',
        bar: 'foo'
      }, 'element');

    });
  });

  describe('...bindPublishers', function() {
    it('...should bind a `click` listener to `.clear-filters`', function(){
      $('body').append('<div class="clear-filters" />');

      moj.Modules.DataTables.bindPublishers();

      spyOn($, 'publish')

      $('.clear-filters').click();

      expect($.publish).toHaveBeenCalledWith('/general/clear-filters/');

    });
  });
});