describe('Modules.AllocationScheme.js', function () {
  const mod = moj.Modules.AllocationScheme
  const filtersFixtureDOM = $('<div id="allocation-filters"/>')

  function resetFilter () {
    $(filtersFixtureDOM).append($('<input name="myname" value="agfs" type="radio" />'))
    $('#allocation-filters input').trigger('change')
  }

  beforeEach(function () {
    $('body').append(filtersFixtureDOM)
  })

  afterEach(function () {
    resetFilter()
    filtersFixtureDOM.remove()
  })

  it('...should exist', function () {
    expect(moj.Modules.AllocationScheme).toBeDefined()
  })

  it('...should have a `this.el` defined', function () {
    expect(mod.el).toEqual('#allocation-filters')
  })

  it('...should cache `this.$el`, ', function () {
    mod.$el = null
    expect(mod.$el).toEqual(null)
    mod.init()
    expect(mod.$el instanceof jQuery).toEqual(true)
  })

  it('...should call `bindEvents`', function () {
    spyOn(mod, 'bindEvents').and.callThrough()
    mod.init()
    expect(mod.bindEvents).toHaveBeenCalled()
  })

  it('...should publish a `/scheme/change/` event and value', function () {
    $(filtersFixtureDOM).append($('<input name="myname" value="input-value" type="radio" />'))
    mod.init()

    spyOn($, 'publish').and.callThrough()

    $('#allocation-filters input').trigger('change')

    expect($.publish).toHaveBeenCalledWith('/scheme/change/', { scheme: 'input-value' })
  })
})
