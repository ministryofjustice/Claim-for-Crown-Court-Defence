describe('Helpers.Autocomplete.js', function() {
  var helper = moj.Helpers.Autocomplete;

  var domFixture = $('<div class="main" />');
  var view = [
    '<input value="case_details" type="hidden" id="claim_form_step" />',
    '<select id="demoselect" class="fx-autocomplete">',
    '<option>-- please select --</option>',
    '<option ',
    'data-is-fixed-fee="true" ',
    'data-requires-cracked-dates="true" ',
    'data-requires-retrial-dates="true" ',
    'data-requires-trial-dates="true" ',
    'value="1">Appeal against conviction</option>',
    '</select>',
    '<div id="cracked-trial-dates">Cracked</div>',
    '<div id="retrial-dates">Retrial</div>',
    '<div id="trial-dates">Trial</div>',
  ].join('');


  beforeEach(function() {
    domFixture.append($(view));
    $('body').append(domFixture);
  });

  afterEach(function() {
    domFixture.empty();
  });

  it('should exist', function() {
    expect(helper).toBeDefined();
  });

  describe('..Methods', function() {
    describe('...new', function() {
      it('should return an error if `element` is not passed in', function() {
        expect(function() {
          helper.new();
        }).toThrowError('Param: `element` is missing or not a string');
      });

      it('should return an error if `element` is not a string', function() {
        expect(function() {
          helper.new({});
        }).toThrowError('Param: `element` is missing or not a string');
      });

      it('should return an error if `element` is missing from the page', function() {
        expect(function() {
          helper.new('#shouldError');
        }).toThrowError('No element found. Usage: `#selector`');
      });

      it('should allow options to be passed it', function() {
        spyOn(accessibleAutocomplete, 'enhanceSelectElement');
        helper.new('#demoselect', {
          something: 'goes here',
          onConfirm: ''
        });

        expect(accessibleAutocomplete.enhanceSelectElement).toHaveBeenCalledWith({
          selectElement: $('#demoselect')[0],
          autoselect: true,
          onConfirm: '',
          something: "goes here",
        });
      });
    });
  });
});
