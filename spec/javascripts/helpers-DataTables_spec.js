describe("Helpers.DataTables.js", function() {
  it('should exist', function() {
    expect(moj.Helpers.DataTables).toBeDefined();
  });


  it('should have default options set', function() {
    // tooooo long to type
    var defaults = moj.Helpers.DataTables._defaultOptions;

    expect(defaults).toBeDefined();

    // deferRender: true
    // Feature control deferred rendering
    // for additional speed of initialisation
    expect(defaults.deferRender).toEqual(true);



  });

});