describe('Helpers.API.Core.js', function () {
  const helper = moj.Helpers.API._CORE

  it('should exist', function () {
    expect(moj.Helpers.API._CORE).toBeDefined()
  })

  it('should have a `query` on the API', function () {
    expect(helper.query).toBeDefined()
  })

  it('should merge `ajaxSettings` with internal defaults', function (done) {
    spyOn($, 'ajax').and.returnValue(Promise.resolve())

    helper.query({
      url: './something.json',
      someting: 'else'
    }).then(function () {
      expect($.ajax).toHaveBeenCalledWith({
        type: 'GET',
        dataType: 'json',
        url: './something.json',
        someting: 'else'
      })
      done()
    })
  })

  it('should return an error if `ajaxSettings.url` is missing', function (done) {
    spyOn($, 'ajax').and.returnValue(Promise.resolve())

    helper.query({}).catch(function (status, error) {
      expect(status).toEqual('error')
      expect(error).toEqual({
        message: 'No URL provided'
      })
    })
    done()
  })
})
