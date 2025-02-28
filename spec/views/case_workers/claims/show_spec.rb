require 'rails_helper'

RSpec.describe 'case_workers/claims/show.html.haml' do
  before do
    @case_worker = create(:case_worker)
    initialize_view_helpers(view)
    sign_in(@case_worker.user, scope: :user)
    allow(view).to receive(:current_user_persona_is?).and_return(false)
  end

  context 'certified claims' do
    before do
      certified_claim
      assign(:claim, @claim)
      render
    end

    it 'displays the name of the external user' do
      expect(rendered).to include('Stepriponikas Bonstart')
    end

    it 'shows the reason for certification' do
      expect(rendered).to include('which ever reason i please')
    end
  end

  context 'trial and retrial claims' do
    it 'shows trial details' do
      trial_claim
      assign(:claim, @claim)
      render
      expect(rendered).to have_content('First day of trial')
    end

    it 'shows retrial details' do
      trial_claim('re')
      assign(:claim, @claim)
      render
      expect(rendered).to have_content('First day of retrial')
    end
  end

  context 'fee summaries' do
    headings = ['Fee category', 'Fee type', 'Quantity', 'Rate', 'Net amount']

    context 'AGFS' do
      before do
        claim.save
        assign(:claim, claim)
        render
      end

      context 'basic fees' do
        let(:claim) { build(:advocate_claim, :without_misc_fees, :submitted) }

        it 'displays expected table headers' do
          headings.each do |heading|
            expect(rendered).to have_css('th', text: heading)
          end
        end
      end

      context 'fixed fees' do
        let(:claim) { build(:advocate_claim, :with_fixed_fee_case, :without_misc_fees, :submitted) }

        it 'displays expected table headers' do
          headings.each do |heading|
            expect(rendered).to have_css('th', text: heading)
          end
        end
      end
    end
  end

  context 'LGFS' do
    before do
      claim.save
      assign(:claim, claim)
      render
    end

    context 'graduated fee' do
      headings = ['Fee category', 'Fee type', 'PPE', 'Actual trial length', 'Amount']
      let(:claim) { build(:litigator_claim, :trial, :submitted) }

      it 'displays expected table headers' do
        headings.each do |heading|
          expect(rendered).to have_css('th', text: heading)
        end
      end
    end

    context 'fixed fee' do
      headings = ['Fee category', 'Fee type', 'Quantity', 'Rate', 'Amount']
      let(:claim) { build(:litigator_claim, :with_fixed_fee_case, :submitted) }

      it 'displays expected table headers' do
        headings.each do |heading|
          expect(rendered).to have_css('th', text: heading)
          expect(rendered).to have_no_css('th', text: 'Actual trial length')
        end
      end
    end

    context 'interim fee' do
      headings = ['Fee category', 'Fee type', 'Amount']
      let(:claim) { build(:interim_claim, :interim_warrant_fee, :submitted) }

      it 'displays expected table headers' do
        headings.each do |heading|
          expect(rendered).to have_css('th', text: heading)
          expect(rendered).to have_no_css('th', text: 'Actual trial length')
        end
      end
    end

    context 'transfer fee' do
      headings = ['Fee category', 'Fee type', 'Days', 'PPE', 'Amount']
      let(:claim) { build(:transfer_claim, :submitted) }

      it 'displays expected table headers' do
        headings.each do |heading|
          expect(rendered).to have_css('th', text: heading)
          expect(rendered).to have_no_css('th', text: 'Actual trial length')
        end
      end
    end
  end

  context 'document checklist' do
    let!(:claim_with_doc) { create(:claim) }
    let!(:document) { create(:document, :verified, claim: claim_with_doc) }

    before do
      allow(view).to receive(:current_user_persona_is?).with(CaseWorker).and_return(true)
      assign(:claim, claim_with_doc)
      render
    end

    it 'displays a `download all` link' do
      expect(rendered).to have_link('Download all')
    end
  end

  context 'calculated travel expense' do
    context 'for litigator claims' do
      subject { rendered }

      let(:claim) { build(:litigator_claim, :with_fixed_fee_case, :submitted, travel_expense_additional_information: Faker::Lorem.paragraph(sentence_count: 1)) }
      let!(:establishment) { create(:establishment, :crown_court, name: 'Basildon', postcode: 'SS14 2EW') }

      before do
        allow(view).to receive(:current_user_persona_is?).with(CaseWorker).and_return(true)

        claim.save
        expense.save
        assign(:claim, claim.reload)
        render
      end

      context 'with a lower rate, non increased calculated distance' do
        let(:expense) { build(:expense, :with_calculated_distance, mileage_rate_id: 1, location: 'Basildon', date: 3.days.ago, claim:) }

        it 'does not render a map link' do
          expect(rendered).to_not have_link_to(/google.*maps.*origin=.*destination=.*/)
          expect(rendered).to have_content('Accepted')
        end
      end

      context 'with a lower rate and a calculated and reduced distance' do
        let(:expense) { build(:expense, :with_calculated_distance_decreased, mileage_rate_id: 1, location: 'Basildon', date: 3.days.ago, claim:) }

        it 'does not render a map link' do
          expect(rendered).to_not have_link_to(/google.*maps.*origin=.*destination=.*/)
          expect(rendered).to have_content('Accepted')
        end
      end

      context 'with a lower rate and a calculated but increased distance' do
        let(:expense) { build(:expense, :with_calculated_distance_increased, mileage_rate_id: 1, location: 'Basildon', date: 3.days.ago, claim:) }

        it 'renders a map link' do
          expect(rendered).to have_link_to(/google.*maps.*origin=.*destination=.*/)
          expect(rendered).to have_link('View car journey')
          expect(rendered).to have_content('Unverified')
        end
      end

      context 'with a higher rate, non increased calculated distance' do
        let(:expense) { build(:expense, :with_calculated_distance, mileage_rate_id: 2, location: 'Basildon', date: 3.days.ago, claim:) }

        it 'renders a map link' do
          expect(rendered).to have_link_to(/google.*maps.*origin=.*destination=.*/)
          expect(rendered).to have_link('View public transport journey')
          expect(rendered).to have_content('Unverified')
        end
      end

      context 'with a higher rate and a calculated and reduced distance' do
        let(:expense) { build(:expense, :with_calculated_distance_decreased, mileage_rate_id: 2, location: 'Basildon', date: 3.days.ago, claim:) }

        it 'renders a map link' do
          expect(rendered).to have_link_to(/google.*maps.*origin=.*destination=.*/)
          expect(rendered).to have_link('View public transport journey')
          expect(rendered).to have_content('Unverified')
        end
      end

      context 'with a higher rate and a calculated but increased distance' do
        let(:expense) { build(:expense, :with_calculated_distance_increased, mileage_rate_id: 2, location: 'Basildon', date: 3.days.ago, claim:) }

        it 'renders a map link' do
          expect(rendered).to have_link_to(%r{www.google.co.uk/maps})
          expect(rendered).to have_link('View public transport journey')
          expect(rendered).to have_content('Unverified')
        end
      end
    end

    context 'for advocate claims' do
      subject { rendered }

      let(:claim) { build(:advocate_claim, :with_fixed_fee_case, :submitted, travel_expense_additional_information: Faker::Lorem.paragraph(sentence_count: 1)) }
      let!(:establishment) { create(:establishment, :crown_court, name: 'Basildon', postcode: 'SS14 2EW') }

      before do
        allow(view).to receive(:current_user_persona_is?).with(CaseWorker).and_return(true)

        claim.save
        expense.save
        assign(:claim, claim.reload)
        render
      end

      context 'with a lower rate, non increased calculated distance' do
        let(:expense) { build(:expense, :with_calculated_distance, mileage_rate_id: 1, location: 'Basildon', date: 3.days.ago, claim:) }

        it 'does not render a map link' do
          expect(rendered).to_not have_link_to(/google.*maps.*origin=.*destination=.*/)
          expect(rendered).to have_no_content('Unverified')
        end
      end

      context 'with a lower rate and a calculated and reduced distance' do
        let(:expense) { build(:expense, :with_calculated_distance_decreased, mileage_rate_id: 1, location: 'Basildon', date: 3.days.ago, claim:) }

        it 'does not render a map link' do
          expect(rendered).to_not have_link_to(/google.*maps.*origin=.*destination=.*/)
          expect(rendered).to have_no_content('Unverified')
        end
      end

      context 'with a lower rate and a calculated but increased distance' do
        let(:expense) { build(:expense, :with_calculated_distance_increased, mileage_rate_id: 1, location: 'Basildon', date: 3.days.ago, claim:) }

        it 'renders a map link' do
          expect(rendered).to_not have_link_to(/google.*maps.*origin=.*destination=.*/)
          expect(rendered).to have_no_link('View car journey')
          expect(rendered).to have_no_content('Unverified')
        end
      end

      context 'with a higher rate, non increased calculated distance' do
        let(:expense) { build(:expense, :with_calculated_distance, mileage_rate_id: 2, location: 'Basildon', date: 3.days.ago, claim:) }

        it 'renders a map link' do
          expect(rendered).to_not have_link_to(/google.*maps.*origin=.*destination=.*/)
          expect(rendered).to have_no_link('View public transport journey')
          expect(rendered).to have_no_content('Unverified')
        end
      end

      context 'with a higher rate and a calculated and reduced distance' do
        let(:expense) { build(:expense, :with_calculated_distance_decreased, mileage_rate_id: 2, location: 'Basildon', date: 3.days.ago, claim:) }

        it 'renders a map link' do
          expect(rendered).to_not have_link_to(/google.*maps.*origin=.*destination=.*/)
          expect(rendered).to have_no_link('View public transport journey')
          expect(rendered).to have_no_content('Unverified')
        end
      end

      context 'with a higher rate and a calculated but increased distance' do
        let(:expense) { build(:expense, :with_calculated_distance_increased, mileage_rate_id: 2, location: 'Basildon', date: 3.days.ago, claim:) }

        it 'renders a map link' do
          expect(rendered).to_not have_link_to(%r{www.google.co.uk/maps})
          expect(rendered).to have_no_link('View public transport journey')
          expect(rendered).to have_no_content('Unverified')
        end
      end
    end
  end

  context 'reject/refuse reasons' do
    let(:claim) { create(:allocated_claim) }

    context 'after messaging feature released' do
      context 'rejected claims' do
        let(:reason_code) { %w[no_amend_rep_order other] }

        before do
          claim.reject!(reason_code:, reason_text: 'rejecting because...')
          @messages = claim.messages.most_recent_last
          @message = claim.messages.build
          assign(:claim, claim.reload)
          render
        end

        it 'does not render reasons section content' do
          expect(rendered).to have_no_content(/Reason(s) provided:/)
          expect(rendered).to have_no_css('li', text: 'No amending representation order')
          expect(rendered).to have_no_css('li', text: 'Other (rejecting because...)')
        end
      end
    end

    context 'before messaging feature released' do
      let(:reason_code) { %w[no_amend_rep_order] }

      context 'rejected claims' do
        before do |example|
          travel_to(Settings.reject_refuse_messaging_released_at - 1) do
            claim.reject!(reason_code:, reason_text: 'rejecting because...')
          end
          @messages = claim.messages.most_recent_last
          @message = claim.messages.build
          if example.metadata[:legacy]
            allow_any_instance_of(ClaimStateTransition).to receive(:reason_code).and_return('wrong_case_no')
          end
          assign(:claim, claim)
          render
        end

        it 'has the correct status display' do
          expect(rendered).to have_css('strong.govuk-tag.app-tag--rejected', text: 'Rejected')
        end

        it 'renders the reason header with the correct tense' do
          expect(rendered).to have_content('Reason provided:')
        end

        it 'renders the full text of the reason' do
          expect(rendered).to have_css('li', text: 'No amending representation order')
        end

        context 'with multiple reasons' do
          let(:reason_code) { %w[no_amend_rep_order case_still_live other] }

          it 'renders the reason header with the correct tense' do
            expect(rendered).to have_content('Reasons provided:')
          end

          it 'renders the full text of the reasons' do
            expect(rendered).to have_css('li', text: 'No amending representation order')
            expect(rendered).to have_css('li', text: 'Case still live')
            expect(rendered).to have_css('li', text: 'Other (rejecting because...)')
          end
        end

        context 'legacy cases with non-array reason codes', :legacy do
          it 'renders the full text of the reason' do
            expect(rendered).to have_css('li', text: 'Incorrect case number')
          end
        end
      end
    end
  end

  context 'injection errors' do
    before do
      certified_claim
      create(:injection_attempt, :with_errors, claim: @claim)
      assign(:claim, @claim)
      render
    end

    it 'displays summary errors' do
      expect(rendered).to have_css('div.govuk-error-summary')
    end

    it 'displays each error message' do
      expect(rendered).to have_css('ul.govuk-list.govuk-error-summary__list > li > a', text: /injection error/, count: 2)
    end
  end

  context 'fee injection warnings' do
    before do
      trial_claim
      create(:injection_attempt, claim: @claim)
      create(:misc_fee, fee_type:, claim: @claim, quantity: 1, amount: 100.00)
      assign(:claim, @claim)
      render
    end

    context 'with CLAR fees' do
      let(:fee_type) { build(:misc_fee_type, :miumu) }

      it 'displays an injection warning' do
        expect(rendered).to have_css('div.js-callout-injection-warning')
      end

      it 'displays the expected text' do
        expect(rendered).to have_text('Warning: Paper heavy case or unused materials fees were not injected')
      end
    end

    context 'with CAV fees' do
      let(:fee_type) { build(:misc_fee_type, :bacav) }

      it 'displays an injection warning' do
        expect(rendered).to have_css('div.js-callout-injection-warning')
      end

      it 'displays the expected text' do
        expect(rendered).to have_text('Warning: Conferences and views were not injected')
      end
    end

    context 'with Additional Prep fee' do
      let(:fee_type) { build(:misc_fee_type, :miapf) }

      it 'displays an injection warning' do
        expect(rendered).to have_css('div.js-callout-injection-warning')
      end

      it 'displays the expected text' do
        expect(rendered).to have_text('Warning: Additional preparation fee was not injected')
      end
    end
  end

  describe 'offence details information' do
    context 'when the claim is for a fixed fee case type' do
      let(:claim) { create(:advocate_claim, :with_fixed_fee_case) }

      it 'does NOT displays offence details section' do
        assign(:claim, claim)
        render
        expect(rendered).to have_no_content('Offence details')
      end
    end

    context 'when the claim is NOT for a fixed fee case type' do
      let(:claim) { create(:advocate_claim, :with_graduated_fee_case) }

      it 'displays offence details section' do
        assign(:claim, claim)
        render
        expect(rendered).to have_content('Offence details')
      end
    end
  end

  describe 'all the main headings' do
    let(:claim) { create(:claim) }

    before do
      @expense = create(:expense, :with_date_attended, claim:)
      create(:date_attended, attended_item: @expense)
      assign(:claim, claim)
      render
    end

    it 'displays basic claim' do
      expect(rendered).to have_content('Basic claim information')
    end

    it 'displays defendant heading' do
      expect(rendered).to have_content('Defendant details')
    end

    it 'displays evidence heading' do
      expect(rendered).to have_content('Evidence')
    end

    it 'displays Fees heading' do
      expect(rendered).to have_content('Fees')
    end

    it 'displays travel expenses heading' do
      expect(rendered).to have_content('Travel expenses')
    end
  end

  def certified_claim
    eu = create(:external_user, :advocate, user: create(:user, first_name: 'Stepriponikas', last_name: 'Bonstart'))
    @claim = create(:allocated_claim, external_user: eu)
    @claim.certification&.destroy
    certification_type = create(:certification_type, name: 'which ever reason i please')
    create(:certification, claim: @claim, certified_by: 'Bobby Legrand', certification_type:)
    @case_worker.claims << @claim
    @claim.reload
    @message = @claim.messages.build
    @claim
  end

  def trial_claim(trial_prefix = nil)
    @claim = create(:submitted_claim, case_type: create(:case_type, :"#{trial_prefix}trial"), evidence_checklist_ids: [1, 9])
    @case_worker.claims << @claim
    create(:document, claim_id: @claim.id, form_id: @claim.form_id)
    @message = @claim.messages.build
    @claim
  end
end
