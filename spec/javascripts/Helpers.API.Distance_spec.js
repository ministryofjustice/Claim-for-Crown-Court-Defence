describe('Helpers.API.Distance.js', function() {
  var helper = moj.Helpers.API.Distance;

  it('should exist', function() {
    expect(moj.Helpers.API.Distance).toBeDefined();
  });

  it('should have a `query` on the API', function() {
    expect(helper.query).toBeDefined();
  });

  describe('...query', function() {
    beforeEach(function() {
      $('body').append('<form id="feature-form" data-claimid="99">here</form>');
    });
    afterEach(function() {
      $('#feature-form').remove();
    });
    it('should set default parameters', function() {
      var deferred = $.Deferred();
      spyOn(moj.Helpers.API._CORE, 'query').and.returnValue(deferred.promise());

      expect(function() {
        helper.query();
      }).toThrowError('Missing params: `ajaxConfig`');

      expect(function() {
        helper.query({
          claimid: 22
        });
      }).toThrowError('Missing param: `params.destination` is required');

      expect(function() {
        helper.query({
          destination: 'Something'
        });
      }).toThrowError('Missing param: `params.claimid` is required');

      deferred.resolve({});
    });
    it('should call `_CORE` with the correct parameters', function() {
      var deferred = $.Deferred();
      spyOn(moj.Helpers.API._CORE, 'query').and.returnValue(deferred.promise());

      helper.query({
        claimid: '99',
        destination: 'Woking'
      }).then(function() {
        expect(moj.Helpers.API._CORE.query).toHaveBeenCalledWith({
          url: '/external_users/claims/99/expenses/calculate_distance',
          type: 'POST',
          data: {
            destination: 'Woking'
          }
        });
      });
      deferred.resolve({});
    });
  });
});
