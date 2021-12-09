/* global $form:writable, $indictmentEvidence:writable, $submitButton:writable, $saveDraftButton:writable */

describe('supportingEvidence', function () {
  const submitCallback = jasmine.createSpy('submit').and.returnValue(false)
  let confirmAlert

  $form = function () {
    return $('#supporting-evidence-fixture-form')
  }

  $submitButton = function () {
    return $('button[name="commit_submit_claim"]')
  }

  $saveDraftButton = function () {
    return $('button[name="commit_save_draft"]')
  }

  $indictmentEvidence = function () {
    return $('#claim_evidence_checklist_ids_4')
  }

  const fixtureDom = $(`
  <div data-mute-indictment="false">
    <form method="post" action="" id="supporting-evidence-fixture-form">
        <fieldset class="checklist">
            <h3>Supporting evidence checklist</h3>
            <div class="govuk-grid-row">
                <div class="govuk-grid-column-one-half">
                    <label class="block-label" for="claim_evidence_checklist_ids_5"><input type="checkbox" value="5" name="claim[evidence_checklist_ids][]" id="claim_evidence_checklist_ids_5">Order in respect of judicial apportionment</label>
                    <label class="block-label" for="claim_evidence_checklist_ids_3"><input type="checkbox" value="3" name="claim[evidence_checklist_ids][]" id="claim_evidence_checklist_ids_3">Committal bundle front sheet(s)</label>
                    <label class="block-label" for="claim_evidence_checklist_ids_4"><input type="checkbox" value="4" name="claim[evidence_checklist_ids][]" id="claim_evidence_checklist_ids_4">A copy of the indictment</label>
                    <label class="block-label" for="claim_evidence_checklist_ids_1"><input type="checkbox" value="1" name="claim[evidence_checklist_ids][]" id="claim_evidence_checklist_ids_1">Representation order</label>
                </div>
                <div class="govuk-grid-column-one-half">
                    <label class="block-label" for="claim_evidence_checklist_ids_8"><input type="checkbox" value="8" name="claim[evidence_checklist_ids][]" id="claim_evidence_checklist_ids_8">Details of previous fee advancements</label>
                    <label class="block-label" for="claim_evidence_checklist_ids_7"><input type="checkbox" value="7" name="claim[evidence_checklist_ids][]" id="claim_evidence_checklist_ids_7">Hardship supporting evidence</label>
                    <label class="block-label" for="claim_evidence_checklist_ids_6"><input type="checkbox" value="6" name="claim[evidence_checklist_ids][]" id="claim_evidence_checklist_ids_6">Expenses invoices</label>
                    <label class="block-label" for="claim_evidence_checklist_ids_9"><input type="checkbox" value="9" name="claim[evidence_checklist_ids][]" id="claim_evidence_checklist_ids_9">Justification for out of time claim</label>
                </div>
            </div>
        </fieldset>
        <div class="button-holder">
            <button type="submit" name="commit_submit_claim" value="Continue" class="govuk-button" data-module="govuk-button">Save and continue</button>
            <button class="govuk-button govuk-button--secondary" data-module="govuk-button">Save a draft</button>
        </div>
    </form>
  </div>
`)
  beforeEach(function () {
    $('body').append(fixtureDom)

    $form().submit(submitCallback)
    confirmAlert = spyOn(window, 'confirm')

    moj.Modules.NewClaim.initSubmitValidation()
  })

  afterEach(function () {
    fixtureDom.remove()
  })

  describe('on claim submit', function () {
    describe('should alert when copy of the indictment is not selected in the supporting evidence checklist', function () {
      it('and do not submit the form if answer to confirm is Cancel', function () {
        confirmAlert.and.returnValue(false)

        $submitButton().trigger('click')

        expect(confirmAlert).toHaveBeenCalled()
        expect(submitCallback).not.toHaveBeenCalled()
      })

      it('and submit the form if answer to confirm is OK', function () {
        confirmAlert.and.returnValue(true)

        $submitButton().trigger('click')

        expect(confirmAlert).toHaveBeenCalled()
        expect(submitCallback).toHaveBeenCalled()
      })
    })

    describe('should not alert when copy of the indictment is selected in the supporting evidence checklist', function () {
      it('and submit the form', function () {
        $indictmentEvidence().trigger('click')

        $submitButton().trigger('click')

        expect(confirmAlert).not.toHaveBeenCalled()
        expect(submitCallback).toHaveBeenCalled()
      })
    })
  })

  describe('on claim save draft', function () {
    describe('should not alert when copy of the indictment is not selected in the supporting evidence checklist', function () {
      it('and submit the form', function () {
        $saveDraftButton().trigger('click')

        expect(confirmAlert).not.toHaveBeenCalled()
        expect(submitCallback).toHaveBeenCalled()
      })
    })
  })
})
