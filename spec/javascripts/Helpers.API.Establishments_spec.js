describe('Helpers.API.Establishments.js', function () {
  const helper = moj.Helpers.API.Establishments
  const fixtureData = [{
    id: 1,
    name: 'HMP One',
    category: 'hospital',
    postcode: 'L9 7LH'
  }, {
    id: 2,
    name: 'HMP Two',
    category: 'prison',
    postcode: 'L9 7LH'
  }, {
    id: 3,
    name: 'HMP Three',
    category: 'crown_court',
    postcode: 'L9 7LH'
  }]

  it('should exist', function () {
    expect(moj.Helpers.API.Establishments).toBeDefined()
  })

  it('should have a `loadData` on the API', function () {
    expect(helper.loadData).toBeDefined()
  })

  describe('...loadData', function () {
    beforeEach(function () {
      $('body').append('<div id="expenses" data-feature-distance="true">here</div>')
    })
    afterEach(function () {
      $('#expenses').remove()
    })

    it('should call `loadData` if the DOM triggers are in place', function (done) {
      spyOn(moj.Helpers.API._CORE, 'query').and.returnValue(Promise.resolve([]))

      helper.init().then(function () {
        expect(moj.Helpers.API._CORE.query).toHaveBeenCalledWith({
          url: '/establishments.json',
          type: 'GET',
          dataType: 'json'
        })
        done()
      })
    })

    it('should call `$.publish` the success event', function (done) {
      spyOn(moj.Helpers.API._CORE, 'query').and.returnValue(Promise.resolve([]))
      spyOn($, 'publish')

      helper.init().then(function () {
        expect($.publish).toHaveBeenCalledWith('/API/establishments/loaded/')
        done()
      })
    })

    it('should call `$.publish` the error event', function (done) {
      const errorData = 'error status'

      spyOn($, 'publish')
      spyOn(moj.Helpers.API._CORE, 'query').and.returnValue(Promise.reject(errorData))

      helper.init().then(function () {
        expect($.publish).toHaveBeenCalledWith('/API/establishments/load/error/', {
          error: undefined,
          status: 'error status'
        })
        done()
      })
    })

    it('should set the internalCache', function (done) {
      const fixtureData = [{
        id: 1,
        name: 'HMP Altcourse',
        category: 'prison',
        postcode: 'L9 7LH'
      }]
      spyOn(moj.Helpers.API._CORE, 'query').and.returnValue(Promise.resolve(fixtureData))

      helper.init().then(function () {
        expect(helper.getLocationByCategory()).toEqual(fixtureData)
        done()
      })
    })
  })

  describe('...getLocationByCategory', function () {
    beforeEach(function () {
      $('body').append('<div id="expenses" data-feature-distance="true">here</div>')
    })
    afterEach(function () {
      $('#expenses').remove()
    })

    it('should return all the data with no params passed', function (done) {
      spyOn(moj.Helpers.API._CORE, 'query').and.returnValue(Promise.resolve(fixtureData))

      helper.init().then(function () {
        expect(helper.getLocationByCategory()).toEqual(fixtureData)
        done()
      })
    })

    it('should filter the results', function (done) {
      spyOn(moj.Helpers.API._CORE, 'query').and.returnValue(Promise.resolve(fixtureData))

      helper.init().then(function () {
        expect(helper.getLocationByCategory('prison')).toEqual([fixtureData[2]])
        expect(helper.getLocationByCategory('crown_court')).toEqual([fixtureData[1]])
        done()
      })
    })
  })

  describe('...getAsOptions', function () {
    beforeEach(function () {
      $('body').append('<div id="expenses" data-feature-distance="true">here</div>')
    })
    afterEach(function () {
      $('#expenses').remove()
    })

    it('should filter the results', function (done) {
      spyOn(moj.Helpers.API._CORE, 'query').and.returnValue(Promise.resolve(fixtureData))

      helper.init().then(function () {
        return Promise.all([
          helper.getAsOptions('prison'),
          helper.getAsOptions('crown_court')
        ])
      }).then(function (results) {
        const [prisonOptions, crownCourtOptions] = results
        expect(prisonOptions).toEqual([
          '<option value="">Please select</option>',
          '<option value="2" data-postcode="L9 7LH">HMP Two</option>'
        ])
        expect(crownCourtOptions).toEqual([
          '<option value="">Please select</option>',
          '<option value="3" data-postcode="L9 7LH">HMP Three</option>'
        ])
        done()
      }).catch(done.fail)
    })
  })
})
