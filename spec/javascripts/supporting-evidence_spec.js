describe('supportingEvidence', function () {
  let confirmAlert
  let submitCallback

  const $form = function () {
    return $('#supporting-evidence-fixture-form')
  }

  const $submitButton = function () {
    return $('button[name="commit_submit_claim"]')
  }

  const $saveDraftButton = function () {
    return $('button[name="commit_save_draft"]')
  }

  const $indictmentEvidence = function () {
    return $('#claim-evidence-checklist-ids-4-field')
  }

  const fixtureDom = $(`
  <div data-mute-indictment="false">
    <form method="post" action="" id="supporting-evidence-fixture-form">
        <fieldset class="checklist">
            <legend>Supporting evidence checklist</legend>
            <div class="govuk-grid-row">
                <div class="govuk-grid-column-one-half">
                    <label class="block-label" for="claim-evidence-checklist-ids-5-field"><input type="checkbox" value="5" name="claim[evidence_checklist_ids][]" id="claim-evidence-checklist-ids-5-field">Order in respect of judicial apportionment</label>
                    <label class="block-label" for="claim-evidence-checklist-ids-3-field"><input type="checkbox" value="3" name="claim[evidence_checklist_ids][]" id="claim-evidence-checklist-ids-3-field">Committal bundle front sheet(s)</label>
                    <label class="block-label" for="claim-evidence-checklist-ids-4-field"><input type="checkbox" value="4" name="claim[evidence_checklist_ids][]" id="claim-evidence-checklist-ids-4-field">Copy of the indictment</label>
                    <label class="block-label" for="claim-evidence-checklist-ids-1-field"><input type="checkbox" value="1" name="claim[evidence_checklist_ids][]" id="claim-evidence-checklist-ids-1-field">Representation order</label>
                </div>
                <div class="govuk-grid-column-one-half">
                    <label class="block-label" for="claim-evidence-checklist-ids-8-field"><input type="checkbox" value="8" name="claim[evidence_checklist_ids][]" id="claim-evidence-checklist-ids-8-field">Details of previous fee advancements</label>
                    <label class="block-label" for="claim-evidence-checklist-ids-7-field"><input type="checkbox" value="7" name="claim[evidence_checklist_ids][]" id="claim-evidence-checklist-ids-7-field">Hardship supporting evidence</label>
                    <label class="block-label" for="claim-evidence-checklist-ids-6-field"><input type="checkbox" value="6" name="claim[evidence_checklist_ids][]" id="claim-evidence-checklist-ids-6-field">Expenses invoices</label>
                    <label class="block-label" for="claim-evidence-checklist-ids-9-field"><input type="checkbox" value="9" name="claim[evidence_checklist_ids][]" id="claim-evidence-checklist-ids-9-field">Justification for out of time claim</label>
                </div>
            </div>
        </fieldset>
        <div class="button-holder">
            <button type="submit" name="commit_submit_claim" value="Continue" class="govuk-button" data-module="govuk-button">Save and continue</button>
            <button class="govuk-button govuk-button--secondary" name="commit_save_draft" data-module="govuk-button">Save a draft</button>
        </div>
    </form>
  </div>
`)

  beforeEach(function () {
    $('body').append(fixtureDom)

    submitCallback = jasmine.createSpy('submit').and.returnValue(false)
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
      afterEach(function () {
        $indictmentEvidence().trigger('click')
      })

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
