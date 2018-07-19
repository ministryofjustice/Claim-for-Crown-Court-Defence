describe('Helpers.API.Core.js', function() {
  var helper = moj.Helpers.API._CORE;

  it('should exist', function() {
    expect(moj.Helpers.API._CORE).toBeDefined();
  });

  it('should have a `query` on the API', function() {
    expect(helper.query).toBeDefined();
  });

  it('should merge `ajaxSettings` with internal defaults', function() {
    var deferred = $.Deferred();

    spyOn($, 'ajax').and.returnValue(deferred.promise());

    var successFn = function() {
      expect($.ajax).toHaveBeenCalledWith({
        type: 'GET',
        dataType: 'json',
        url: './something.json',
        someting: 'else'
      });
    };


    helper.query({
      url: './something.json',
      someting: 'else'
    }, {
      success: successFn
    });

    deferred.resolve('This is the result');
  });

  it('should return an error if `ajaxSettings.url` is missing', function() {
    var deferred = $.Deferred();

    spyOn($, 'ajax').and.returnValue(deferred.promise());

    var errorFn = function(status, error) {
      expect(status).toEqual('error');
      expect(error).toEqual({
        message: 'No URL provided'
      });
    };

    helper.query({}, {
      error: errorFn
    });

    deferred.reject('error', {
      message: 'No URL provided'
    });
  });
});
