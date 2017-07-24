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
    expect(defaults.pagingType).toEqual('full_numbers');

    // pageLength:
    // Set the initial page length, current: 10
    //
    // https://datatables.net/reference/option/pageLength
    expect(defaults.pageLength).toEqual(10);

    // columnDefs:
    // https://datatables.net/reference/option/columnDefs
    // expect(defaults.columnDefs).toBeDefined();

    // columns:
    // https://datatables.net/reference/option/columns
    // For the JSON structure the API returns, the `columnDefs`
    // config is better suited.
    expect(defaults.columns).not.toBeDefined();
  })

  describe('...defaults.columnDefs', function() {
    var columnDefs = defaults.columnDefs;



  });
});