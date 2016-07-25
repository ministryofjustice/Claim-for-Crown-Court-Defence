describe('supportingEvidence', function () {

  var submitCallback = jasmine.createSpy('submit').and.returnValue(false),
      confirmAlert;

  $form = function() {
    return $('#supporting-evidence-fixture-form');
  };

  $submitButton = function() {
    return $('input[name="commit_submit_claim"]');
  };

  $saveDraftButton = function() {
    return $('input[name="commit_save_draft"]');
  };

  $indictmentEvidence = function() {
    return $('#claim_evidence_checklist_ids_4');
  };

  beforeEach(function () {
    loadFixtures('supporting-evidence.html');

    $form().submit(submitCallback);
    confirmAlert = spyOn(window, 'confirm');

    moj.Modules.NewClaim.initSubmitValidation();
  });


  describe('on claim submit', function() {

    describe('should alert when copy of the indictment is not selected in the supporting evidence checklist', function() {

      it('and do not submit the form if answer to confirm is Cancel', function() {
        confirmAlert.and.returnValue(false);

        $submitButton().click();

        expect(confirmAlert).toHaveBeenCalled();
        expect(submitCallback).not.toHaveBeenCalled();
      });

      it('and submit the form if answer to confirm is OK', function() {
        confirmAlert.and.returnValue(true);

        $submitButton().click();

        expect(confirmAlert).toHaveBeenCalled();
        expect(submitCallback).toHaveBeenCalled();
      });

    });

    describe('should not alert when copy of the indictment is selected in the supporting evidence checklist', function() {

      it('and submit the form', function() {
        $indictmentEvidence().click();

        $submitButton().click();

        expect(confirmAlert).not.toHaveBeenCalled();
        expect(submitCallback).toHaveBeenCalled();
      });

    });

  });


  describe('on claim save draft', function() {

    describe('should not alert when copy of the indictment is not selected in the supporting evidence checklist', function() {

      it('and submit the form', function() {
        $saveDraftButton().click();

        expect(confirmAlert).not.toHaveBeenCalled();
        expect(submitCallback).toHaveBeenCalled();
      });

    });

  });

});
