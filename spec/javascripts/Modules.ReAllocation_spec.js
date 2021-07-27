describe('Modules.ReAllocation.js', function () {
  const module = moj.Modules.ReAllocation
  const domFixture = $(
    '<div class="js-re-allocation-page">',
    '<div class="fx-autocomplete-wrapper">',
    '<select>',
    '<option value="1">Option 1</option>',
    '</select>',
    '</div>',
    '</div>')

  beforeEach(function () {
    $('body').append(domFixture)
  })

  afterEach(function () {
    domFixture.remove()
  })

  it('...should exist', function () {
    expect(module).toBeDefined()
  })

  it('...should init autocomplete', function () {
    spyOn(moj.Helpers.Autocomplete, 'new')
    module.init()
    expect(moj.Helpers.Autocomplete.new).toHaveBeenCalledWith('.fx-autocomplete-wrapper select', { showAllValues: true, autoselect: false, displayMenu: 'overlay' })
  })
})
