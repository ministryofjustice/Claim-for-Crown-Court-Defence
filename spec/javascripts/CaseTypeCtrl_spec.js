describe('Modules.CaseTypeCtrl', function() {
  var CaseTypeCtrl = moj.Modules.CaseTypeCtrl;

  var domFixture = $('<div class="main" />');
  var view = [
    '<input value="case_details" type="hidden" id="claim_form_step" />'
  ].join('');

  beforeEach(function() {
    domFixture.append($(view));
    $('body').append(domFixture);
  });

  afterEach(function() {
    domFixture.empty();
  });

  it('should have a default `el` defined', function() {
    expect(CaseTypeCtrl.els).toEqual({
      requiresCrackedDates: '#cracked-trial-dates',
      requiresRetrialDates: '#retrial-dates',
      requiresTrialDates: '#trial-dates',
      fxAutocomplete: '.fx-autocomplete'
    });
  });

  describe('Methods', function() {
    describe('...init', function() {
      it('...should call `this.bindEvents` if activated', function() {
        spyOn(CaseTypeCtrl, 'bindEvents');

        $('#claim_form_step').val('NO NO NO');
        CaseTypeCtrl.init();

        expect(CaseTypeCtrl.bindEvents).not.toHaveBeenCalled();

        $('#claim_form_step').val('case_details');

        CaseTypeCtrl.init();

        expect(CaseTypeCtrl.bindEvents).toHaveBeenCalled();
      });

      it('...should call `this.initAutocomplete` if activated', function() {
        spyOn(CaseTypeCtrl, 'initAutocomplete');

        $('#claim_form_step').val('NO NO NO');
        CaseTypeCtrl.init();

        expect(CaseTypeCtrl.initAutocomplete).not.toHaveBeenCalled();

        $('#claim_form_step').val('case_details');

        CaseTypeCtrl.init();

        expect(CaseTypeCtrl.initAutocomplete).toHaveBeenCalled();
      });
    });

    describe('...bindEvents', function() {
      it('...should `$.subscribe` to `/onConfirm/claim_case_type_id-select/`', function() {
        spyOn($, 'subscribe');

        CaseTypeCtrl.init();

        expect($.subscribe).toHaveBeenCalled();

      });
    });
    describe('...initAutocomplete', function() {
      it('...should call `initAutocomplete` for each `.fx-autocomplete`', function() {
        spyOn(moj.Helpers.Autocomplete, 'new');

        CaseTypeCtrl.init();

        expect(moj.Helpers.Autocomplete.new).toHaveBeenCalled();
      });
    });
  });
});
