describe('Modules.CaseTypeCtrl', function() {
  var CaseTypeCtrl = moj.Modules.CaseTypeCtrl;

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
      it('...should `$.subscribe` to `/onConfirm/case_type-select/`', function() {
        spyOn($, 'subscribe');

        CaseTypeCtrl.init();

        expect($.subscribe).toHaveBeenCalled();

      });

      it('should trigger the `actions` methods', function() {
        CaseTypeCtrl.init();

        spyOn(CaseTypeCtrl.actions, 'requiresTrialDates');
        spyOn(CaseTypeCtrl.actions, 'requiresRetrialDates');
        spyOn(CaseTypeCtrl.actions, 'requiresCrackedDates');

        $.publish('/onConfirm/case_type-select/', {
          requiresCrackedDates: true,
          requiresRetrialDates: false,
          requiresTrialDates: true
        });

        expect(CaseTypeCtrl.actions.requiresTrialDates).toHaveBeenCalledWith(true, CaseTypeCtrl);
        expect(CaseTypeCtrl.actions.requiresRetrialDates).toHaveBeenCalledWith(false, CaseTypeCtrl);
        expect(CaseTypeCtrl.actions.requiresCrackedDates).toHaveBeenCalledWith(true, CaseTypeCtrl);

      });
    });

    describe('...initAutocomplete', function() {
      it('...should call `initAutocomplete` for each `.fx-autocomplete`', function() {
        spyOn(moj.Helpers.Autocomplete, 'new');

        CaseTypeCtrl.init();

        expect(moj.Helpers.Autocomplete.new).toHaveBeenCalled();
      });
    });

    describe('...actions.requiresTrialDates', function() {
      it('should call `toggle` on the element and pass the params', function() {
        spyOn(CaseTypeCtrl, 'toggle');
        CaseTypeCtrl.actions.requiresTrialDates(true, CaseTypeCtrl);
        expect(CaseTypeCtrl.toggle).toHaveBeenCalledWith('#trial-dates', true);
      });
    });

    describe('...actions.requiresRetrialDates', function() {
      it('should call `toggle` on the element and pass the params', function() {
        spyOn(CaseTypeCtrl, 'toggle');
        CaseTypeCtrl.actions.requiresRetrialDates(false, CaseTypeCtrl);
        expect(CaseTypeCtrl.toggle).toHaveBeenCalledWith('#retrial-dates', false);
      });
    });
    describe('...actions.requiresCrackedDates', function() {
      it('should call `toggle` on the element and pass the params', function() {
        spyOn(CaseTypeCtrl, 'toggle');
        CaseTypeCtrl.actions.requiresCrackedDates(true, CaseTypeCtrl);
        expect(CaseTypeCtrl.toggle).toHaveBeenCalledWith('#cracked-trial-dates', true);
      });
    });

  });
});
