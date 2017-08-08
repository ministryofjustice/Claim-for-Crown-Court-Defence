describe("Helpers.DataTables.js", function() {
  var helper = moj.Helpers.DataTables;
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

  it('...should call `$.fn.DataTable`', function() {
    spyOn($.fn, 'DataTable');

    helper.init({
      some: 'param'
    }, '<div/>');

    expect($.fn.DataTable).toHaveBeenCalledWith({
      deferRender: true,
      some: 'param'
    });
  });

  it('...should extend and override default options', function() {
    spyOn($.fn, 'DataTable');

    helper.init({
      deferRender: 99,
      more: 'params'
    }, '<div/>');

    expect($.fn.DataTable).toHaveBeenCalledWith({
      deferRender: 99,
      more: 'params'
    });
  });

});