describe('Helpers.FormControls.js', function() {
  var helper = moj.Helpers.FormControls;

  describe('...select', function() {
    it('...should be defined and be a function', function() {
      expect(helper.select).toBeDefined();
      expect(helper.select).toEqual({
        getSelect: jasmine.any(Function)
      });
    });
  });

  describe('...getSelect', function() {
    it('...should be defined and be a function', function() {
      expect(helper.getSelect).toBeDefined();
      expect(helper.getSelect).toEqual(jasmine.any(Function));
    });

    it('...should return an empty `<select />`, called with no params', function() {
      expect(helper.getSelect()).toEqual('<select name="" id=""></select>');
    });

    it('...should warp any `<option />` passed as params', function() {
      expect(helper.getSelect(['<option name="one">One</option>'])).toEqual('<select name="" id=""><option name="one">One</option></select>');
    });
  });

  describe('...selectOptions', function() {
    it('...should be defined and be a function', function() {
      expect(helper.selectOptions).toBeDefined();
      expect(helper.selectOptions).toEqual({
        getOptions: jasmine.any(Function)
      });
    });
  });

  describe('...getOptions', function() {
    it('...should be defined and be a function', function() {
      expect(helper.getOptions).toBeDefined();
      expect(helper.getOptions).toEqual(jasmine.any(Function));
    });

    it('...should return an `Error` if no params passed', function() {
      expect(function() {
        helper.getOptions();
      }).toThrowError('Missing param: collection');
    });

    it('...should return an array of options in a promise', function() {
      helper.getOptions([{
        id: 'id',
        postcode: 'postcode',
        name: 'name'
      }]).then(function(el) {
        expect(el).toEqual(['<option value="">Please select</option>', '<option value="id" data-postcode="postcode">name</option>']);
      });
    });

    it('...should set the selected option', function() {

      helper.getOptions([{
        id: 'id',
        postcode: 'postcode',
        name: 'name'
      }], {value: 'name', prop: 'name'}).then(function(el) {
        expect(el).toEqual(['<option value="">Please select</option>', '<option value="id" selected="" data-postcode="postcode">name</option>']);
      });
    });

  });
});
