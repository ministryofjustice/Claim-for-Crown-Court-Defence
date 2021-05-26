describe('Modules.Allocation.js', function () {
  const mod = moj.Modules.Allocation
  const filtersFixtureDOM = $('<div class="js-allocation-page"><div class="fx-autocomplete-wrapper"><select id="sampleID"><option value="1">Option 1</option></select></div></div>')

  beforeEach(function () {
    $('body').append(filtersFixtureDOM)
  })

  afterEach(function () {
    filtersFixtureDOM.remove()
  })

  it('...should exist', function () {
    expect(moj.Modules.Allocation).toBeDefined()
  })

  it('...should init autocomplete', function () {
    spyOn(moj.Helpers.Autocomplete, 'new')
    mod.init()
    expect(moj.Helpers.Autocomplete.new).toHaveBeenCalledWith('#sampleID', { showAllValues: true, autoselect: false, displayMenu: 'overlay' })
  })
})
