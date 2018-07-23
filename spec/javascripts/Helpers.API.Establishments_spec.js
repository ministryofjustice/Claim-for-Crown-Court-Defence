describe('Helpers.API.Establishments.js', function() {
  var helper = moj.Helpers.API.Establishments;

  it('should exist', function() {
    expect(moj.Helpers.API.Establishments).toBeDefined();
  });

  it('should have a `loadData` on the API', function() {
    expect(helper.loadData).toBeDefined();
  });

  describe('...dataLoad', function() {
    beforeEach(function() {
      $('body').append('<div id="expenses" data-feature-distance="true">here</div>');
    });
    afterEach(function() {
      $('#expenses').remove();
    });

    it('should call `loadData` if the DOM triggers are in place', function() {
      var deferred = $.Deferred();
      spyOn(moj.Helpers.API._CORE, 'query').and.returnValue(deferred.promise());

      helper.init().then(function() {
        expect(moj.Helpers.API._CORE.query).toHaveBeenCalledWith({
          url: '/establishments.json',
          type: 'GET',
          dataType: 'json'
        });
      });
      deferred.resolve({});
    });

    it('should call `$.publish` the success event', function() {
      var deferred = $.Deferred();
      spyOn(moj.Helpers.API._CORE, 'query').and.returnValue(deferred.promise());

      spyOn($, 'publish');

      helper.init().then(function() {
        expect($.publish).toHaveBeenCalledWith('/API/expenses/loaded/');
      });
      deferred.resolve();
    });

    it('should call `$.publish` the error event', function() {
      var deferred = $.Deferred();
      spyOn(moj.Helpers.API._CORE, 'query').and.returnValue(deferred.promise());

      spyOn($, 'publish');

      helper.init().then(function() {}, function() {
        expect($.publish).toHaveBeenCalledWith('/API/expenses/load/error/', {
          status: 'status',
          error: 'error'
        });
      });
      deferred.reject('status', 'error');
    });

    it('should set the internalCache', function() {
      var deferred = $.Deferred();
      spyOn(moj.Helpers.API._CORE, 'query').and.returnValue(deferred.promise());

      helper.init().then(function() {
        expect(helper.getLocationByCategory()).toEqual([{
          "id": 1,
          "name": "HMP Altcourse",
          "category": "prison",
          "postcode": "L9 7LH"
        }]);
      });
      deferred.resolve([{
        "id": 1,
        "name": "HMP Altcourse",
        "category": "prison",
        "postcode": "L9 7LH"
      }]);
    });
  });

  describe('...getLocationByCategory', function() {
    beforeEach(function() {
      $('body').append('<div id="expenses" data-feature-distance="true">here</div>');
    });
    afterEach(function() {
      $('#expenses').remove();
    });

    it('should return all the data with no params passed', function() {
      var deferred = $.Deferred();
      var fixtureData = [{
        "id": 1,
        "name": "HMP One",
        "category": "hospital",
        "postcode": "L9 7LH"
      }, {
        "id": 2,
        "name": "HMP Two",
        "category": "prison",
        "postcode": "L9 7LH"
      }, {
        "id": 3,
        "name": "HMP Three",
        "category": "crown_court",
        "postcode": "L9 7LH"
      }];
      spyOn(moj.Helpers.API._CORE, 'query').and.returnValue(deferred.promise());

      helper.init().then(function() {
        expect(helper.getLocationByCategory()).toEqual(fixtureData);
      });
      deferred.resolve(fixtureData);
    });

    it('should filter the results', function() {
      var deferred = $.Deferred();
      var fixtureData = [{
        "id": 1,
        "name": "HMP One",
        "category": "hospital",
        "postcode": "L9 7LH"
      }, {
        "id": 2,
        "name": "HMP Two",
        "category": "prison",
        "postcode": "L9 7LH"
      }, {
        "id": 3,
        "name": "HMP Three",
        "category": "crown_court",
        "postcode": "L9 7LH"
      }];
      spyOn(moj.Helpers.API._CORE, 'query').and.returnValue(deferred.promise());

      helper.init().then(function() {

        expect(helper.getLocationByCategory('prison')).toEqual([fixtureData[1]]);

        expect(helper.getLocationByCategory('crown_court')).toEqual([fixtureData[2]]);
      });
      deferred.resolve(fixtureData);
    });
  });

  describe('...getAsOptions', function() {
    beforeEach(function() {
      $('body').append('<div id="expenses" data-feature-distance="true">here</div>');
    });
    afterEach(function() {
      $('#expenses').remove();
    });

    it('should filter the results', function() {
      var deferred = $.Deferred();
      var fixtureData = [{
        "id": 1,
        "name": "HMP One",
        "category": "hospital",
        "postcode": "L9 7LH"
      }, {
        "id": 2,
        "name": "HMP Two",
        "category": "prison",
        "postcode": "L9 7LH"
      }, {
        "id": 3,
        "name": "HMP Three",
        "category": "crown_court",
        "postcode": "L9 7LH"
      }];
      spyOn(moj.Helpers.API._CORE, 'query').and.returnValue(deferred.promise());

      helper.init().then(function() {
        helper.getAsOptions('prison').then(function(el) {
          expect(el).toEqual(['<option value="">Please select</option>', '<option data-postcode="L9 7LH" value="2">HMP Two</option>']);
        });
        helper.getAsOptions('crown_court').then(function(el) {
          expect(el).toEqual(['<option value="">Please select</option>', '<option data-postcode="L9 7LH" value="3">HMP Three</option>']);
        });
      });
      deferred.resolve(fixtureData);
    });
  });
});
