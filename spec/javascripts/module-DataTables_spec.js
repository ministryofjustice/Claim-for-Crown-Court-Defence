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
      [10, 25, 50, -1],
      [10, 25, 50, "All"]
    ]);
  });

  describe('...init', function() {
    it('...should merge options with defaults and call `moj.Helpers.DataTables.init`', function() {
      // Spy on the final call
      spyOn(moj.Helpers.DataTables, 'init');

      // Setup some simple defaults
      moj.Modules.DataTables._defaultOptions = {
        foo: 'bar'
      };

      // Call the init passinf in options
      moj.Modules.DataTables.init({
        bar: 'foo'
      }, 'element');


      expect(moj.Helpers.DataTables.init).toHaveBeenCalledWith({
        foo: 'bar',
        bar: 'foo'
      }, 'element');

    });
  });
});