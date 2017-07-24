describe("Modules.AllocationFilters.js", function() {
  var mod = moj.Modules.AllocationFilters;
  var filtersFixtureDOM = $('<div id="allocation-filters"/>');

  beforeEach(function() {
    $('body').append(filtersFixtureDOM);
  });

  afterEach(function() {
    filtersFixtureDOM.remove();
  });


  it('...should exist', function() {
    expect(moj.Modules.AllocationFilters).toBeDefined();
  });

  it('...should have a `this.el` defined', function() {
    expect(mod.el).toEqual('#allocation-filters');
  })

  it('...should cache `this.$el`, ', function() {
    mod.$el = null;
    expect(mod.$el).toEqual(null);
    mod.init();
    expect(mod.$el instanceof jQuery).toEqual(true);
  });

  it('...should call `bindEvents`', function() {
    spyOn(mod, 'bindEvents').and.callThrough();
    mod.init();
    expect(mod.bindEvents).toHaveBeenCalled();
  });

  it('...should publish a `/scheme/change/` event and value', function(){

    $(filtersFixtureDOM).append($('<input name="myname" value="input-value" type="radio" />'));
    mod.init();

    spyOn($, 'publish').and.callThrough();

    $('#allocation-filters input').change();

    expect($.publish).toHaveBeenCalledWith('/scheme/change/', {scheme:'input-value'});

  });

});