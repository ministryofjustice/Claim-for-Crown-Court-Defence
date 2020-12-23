describe('Helpers.API.Core.js', function () {
  const helper = moj.Helpers.API._CORE

  it('should exist', function () {
    expect(moj.Helpers.API._CORE).toBeDefined()
  })

  it('should have a `query` on the API', function () {
    expect(helper.query).toBeDefined()
  })

  it('should merge `ajaxSettings` with internal defaults', function () {
    const deferred = $.Deferred()

    spyOn($, 'ajax').and.returnValue(deferred.promise())

    const successFn = function () {
      expect($.ajax).toHaveBeenCalledWith({
        type: 'GET',
        dataType: 'json',
        url: './something.json',
        someting: 'else'
      })
    }

    helper.query({
      url: './something.json',
      someting: 'else'
    }, {
      success: successFn
    })

    deferred.resolve('This is the result')
  })

  it('should return an error if `ajaxSettings.url` is missing', function () {
    const deferred = $.Deferred()

    spyOn($, 'ajax').and.returnValue(deferred.promise())

    const errorFn = function (status, error) {
      expect(status).toEqual('error')
      expect(error).toEqual({
        message: 'No URL provided'
      })
    }

    helper.query({}, {
      error: errorFn
    })

    deferred.reject('error', {
      message: 'No URL provided'
    })
  })
})
