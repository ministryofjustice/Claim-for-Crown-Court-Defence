describe("Modules.Allocation.js", function() {
  var mod = moj.Modules.Allocation;
  var filtersFixtureDOM = $('<div class="js-allocation-page"><select id="sampleID" class="fx-autocomplete"><option value="1">Option 1</option></select></div>');

  beforeEach(function() {
    $('body').append(filtersFixtureDOM);
  });

  afterEach(function() {
    filtersFixtureDOM.remove();
  });

  it('...should exist', function() {
    expect(moj.Modules.Allocation).toBeDefined();
  });

  it('...should init autocomplete', function() {
    spyOn(moj.Helpers.Autocomplete, 'new');
    mod.init();
    expect(moj.Helpers.Autocomplete.new).toHaveBeenCalledWith('#sampleID', { showAllValues: true, autoselect: false, displayMenu: 'overlay' });
  });
});
