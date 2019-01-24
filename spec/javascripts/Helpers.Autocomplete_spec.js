describe('Helpers.Autocomplete.js', function() {
  var helper = moj.Helpers.Autocomplete;

  var domFixture = $('<div class="main" />');
  var view = [
    '<select id="fx-autocomplete"><option>-- please select --</option></select>'
  ].join('');


  beforeEach(function() {
    domFixture.append($(view));
    $('body').append(domFixture);
  });

  afterEach(function() {
    domFixture.empty();
  });

  it('should exist', function() {
    helper.new('#fx-autocomplete');
    expect(helper).toBeDefined();
  });

  describe('..Methods', function() {
    describe('...new', function() {
      it('should return an error if `element` is missing', function() {
        expect(function() {
          helper.new();
        }).toThrowError('Param: `element` is missing or not a string');
      });

      it('should return an error if `element` is not a string', function() {
        expect(function() {
          helper.new({});
        }).toThrowError('Param: `element` is missing or not a string');
      });

      it('should return an error if `element` is missing', function() {
        expect(function() {
          helper.new('#shouldError');
        }).toThrowError('No element found. Usage: `#selector`');
      });


    });
  });
});
