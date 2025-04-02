require 'rails_helper'

RSpec.describe 'case_workers/claims/show.html.haml' do
  subject { rendered }

  let(:case_worker) { create(:case_worker) }

  before do
    initialize_view_helpers(view)
    sign_in(case_worker.user, scope: :user)
    allow(view).to receive(:current_user_persona_is?).and_return(false)
  end

  context 'with certified claims' do
    before do
      assign(:claim, certified_claim)
      render
    end

    it { is_expected.to include('Stepriponikas Bonstart') }
    it { is_expected.to include('which ever reason i please') }
  end

  context 'with a trial' do
    before do
      assign(:claim, trial_claim)
      render
    end

    it { is_expected.to have_content('First day of trial') }
  end

  context 'with a retrial' do
    before do
      assign(:claim, trial_claim('re'))
      render
    end

    it { is_expected.to have_content('First day of retrial') }
  end

  context 'with fee summaries' do
    let(:headings) { ['Fee category', 'Fee type', 'Quantity', 'Rate', 'Net amount'] }

    context 'with an AGFS claim' do
      before do
        claim.save
        assign(:claim, claim)
        render
      end

      context 'with basic fees' do
        let(:claim) { build(:advocate_claim, :without_misc_fees, :submitted) }

        it 'displays expected table headers' do
          headings.each do |heading|
            expect(rendered).to have_css('th', text: heading)
          end
        end
      end

      context 'with fixed fees' do
        let(:claim) { build(:advocate_claim, :with_fixed_fee_case, :without_misc_fees, :submitted) }

        it 'displays expected table headers' do
          headings.each do |heading|
            expect(rendered).to have_css('th', text: heading)
          end
        end
      end
    end

    context 'with an LGFS claim' do
      let(:headings) { ['Fee category', 'Fee type', 'PPE', 'Actual trial length', 'Amount'] }

      before do
        claim.save
        assign(:claim, claim)
        render
      end

      context 'with a graduated fee' do
        let(:claim) { build(:litigator_claim, :trial, :submitted) }

        it 'displays expected table headers' do
          headings.each do |heading|
            expect(rendered).to have_css('th', text: heading)
          end
        end
      end

      context 'with a fixed fee' do
        let(:headings) { ['Fee category', 'Fee type', 'Quantity', 'Rate', 'Amount'] }
        let(:claim) { build(:litigator_claim, :with_fixed_fee_case, :submitted) }

        it 'displays expected table headers' do
          headings.each do |heading|
            expect(rendered).to have_css('th', text: heading)
          end
        end

        it { expect(rendered).to have_no_css('th', text: 'Actual trial length') }
      end

      context 'with an interim fee' do
        let(:headings) { ['Fee category', 'Fee type', 'Amount'] }
        let(:claim) { build(:interim_claim, :interim_warrant_fee, :submitted) }

        it 'displays expected table headers' do
          headings.each do |heading|
            expect(rendered).to have_css('th', text: heading)
          end
        end

        it { expect(rendered).to have_no_css('th', text: 'Actual trial length') }
      end

      context 'with a transfer fee' do
        let(:headings) { ['Fee category', 'Fee type', 'Days', 'PPE', 'Amount'] }
        let(:claim) { build(:transfer_claim, :submitted) }

        it 'displays expected table headers' do
          headings.each do |heading|
            expect(rendered).to have_css('th', text: heading)
          end
        end

        it { expect(rendered).to have_no_css('th', text: 'Actual trial length') }
      end
    end
  end

  context 'with a document checklist' do
    let!(:claim_with_doc) { create(:claim) }

    before do
      allow(view).to receive(:current_user_persona_is?).with(CaseWorker).and_return(true)
      create(:document, :verified, claim: claim_with_doc)
      assign(:claim, claim_with_doc)
      render
    end

    it { is_expected.to have_link('Download all') }
  end

  context 'with calculated travel expense' do
    context 'with an LGFS claim' do
      let(:claim) do
        build(:litigator_claim, :with_fixed_fee_case, :submitted,
              travel_expense_additional_information: Faker::Lorem.paragraph(sentence_count: 1))
      end

      before do
        allow(view).to receive(:current_user_persona_is?).with(CaseWorker).and_return(true)
        create(:establishment, :crown_court, name: 'Basildon', postcode: 'SS14 2EW')
        claim.save
        expense.save
        assign(:claim, claim.reload)
        render
      end

      context 'with a lower rate, non increased calculated distance' do
        let(:expense) do
          build(:expense, :with_calculated_distance, mileage_rate_id: 1, location: 'Basildon', date: 3.days.ago, claim:)
        end

        it { is_expected.not_to have_link_to(/google.*maps.*origin=.*destination=.*/) }
        it { is_expected.to have_content('Accepted') }
      end

      context 'with a lower rate and a calculated and reduced distance' do
        let(:expense) do
          build(:expense, :with_calculated_distance_decreased, mileage_rate_id: 1, location: 'Basildon',
                                                               date: 3.days.ago, claim:)
        end

        it { is_expected.not_to have_link_to(/google.*maps.*origin=.*destination=.*/) }
        it { is_expected.to have_content('Accepted') }
      end

      context 'with a lower rate and a calculated but increased distance' do
        let(:expense) do
          build(:expense, :with_calculated_distance_increased, mileage_rate_id: 1, location: 'Basildon',
                                                               date: 3.days.ago, claim:)
        end

        it { is_expected.to have_link_to(/google.*maps.*origin=.*destination=.*/) }
        it { is_expected.to have_link('View car journey') }
        it { is_expected.to have_content('Unverified') }
      end

      context 'with a higher rate, non increased calculated distance' do
        let(:expense) do
          build(:expense, :with_calculated_distance, mileage_rate_id: 2, location: 'Basildon', date: 3.days.ago, claim:)
        end

        it { is_expected.to have_link_to(/google.*maps.*origin=.*destination=.*/) }
        it { is_expected.to have_link('View public transport journey') }
        it { is_expected.to have_content('Unverified') }
      end

      context 'with a higher rate and a calculated and reduced distance' do
        let(:expense) do
          build(:expense, :with_calculated_distance_decreased, mileage_rate_id: 2, location: 'Basildon',
                                                               date: 3.days.ago, claim:)
        end

        it { is_expected.to have_link_to(/google.*maps.*origin=.*destination=.*/) }
        it { is_expected.to have_link('View public transport journey') }
        it { is_expected.to have_content('Unverified') }
      end

      context 'with a higher rate and a calculated but increased distance' do
        let(:expense) do
          build(:expense, :with_calculated_distance_increased, mileage_rate_id: 2, location: 'Basildon',
                                                               date: 3.days.ago, claim:)
        end

        it { is_expected.to have_link_to(/google.*maps.*origin=.*destination=.*/) }
        it { is_expected.to have_link('View public transport journey') }
        it { is_expected.to have_content('Unverified') }
      end
    end

    context 'with an AGFS claim' do
      let(:claim) do
        build(:advocate_claim, :with_fixed_fee_case, :submitted,
              travel_expense_additional_information: Faker::Lorem.paragraph(sentence_count: 1))
      end

      before do
        allow(view).to receive(:current_user_persona_is?).with(CaseWorker).and_return(true)
        create(:establishment, :crown_court, name: 'Basildon', postcode: 'SS14 2EW')
        claim.save
        expense.save
        assign(:claim, claim.reload)
        render
      end

      context 'with a lower rate, non increased calculated distance' do
        let(:expense) do
          build(:expense, :with_calculated_distance, mileage_rate_id: 1, location: 'Basildon', date: 3.days.ago, claim:)
        end

        it { is_expected.not_to have_link_to(/google.*maps.*origin=.*destination=.*/) }
        it { is_expected.to have_no_content('Unverified') }
      end

      context 'with a lower rate and a calculated and reduced distance' do
        let(:expense) do
          build(:expense, :with_calculated_distance_decreased, mileage_rate_id: 1, location: 'Basildon',
                                                               date: 3.days.ago, claim:)
        end

        it { is_expected.not_to have_link_to(/google.*maps.*origin=.*destination=.*/) }
        it { is_expected.to have_no_content('Unverified') }
      end

      context 'with a lower rate and a calculated but increased distance' do
        let(:expense) do
          build(:expense, :with_calculated_distance_increased, mileage_rate_id: 1, location: 'Basildon',
                                                               date: 3.days.ago, claim:)
        end

        it { is_expected.not_to have_link_to(/google.*maps.*origin=.*destination=.*/) }
        it { is_expected.to have_no_link('View car journey') }
        it { is_expected.to have_no_content('Unverified') }
      end

      context 'with a higher rate, non increased calculated distance' do
        let(:expense) do
          build(:expense, :with_calculated_distance, mileage_rate_id: 2, location: 'Basildon', date: 3.days.ago, claim:)
        end

        it { is_expected.not_to have_link_to(/google.*maps.*origin=.*destination=.*/) }
        it { is_expected.to have_no_link('View public transport journey') }
        it { is_expected.to have_no_content('Unverified') }
      end

      context 'with a higher rate and a calculated and reduced distance' do
        let(:expense) do
          build(:expense, :with_calculated_distance_decreased, mileage_rate_id: 2, location: 'Basildon',
                                                               date: 3.days.ago, claim:)
        end

        it { is_expected.not_to have_link_to(/google.*maps.*origin=.*destination=.*/) }
        it { is_expected.to have_no_link('View public transport journey') }
        it { is_expected.to have_no_content('Unverified') }
      end

      context 'with a higher rate and a calculated but increased distance' do
        let(:expense) do
          build(:expense, :with_calculated_distance_increased, mileage_rate_id: 2, location: 'Basildon',
                                                               date: 3.days.ago, claim:)
        end

        it { is_expected.not_to have_link_to(/google.*maps.*origin=.*destination=.*/) }
        it { is_expected.to have_no_link('View public transport journey') }
        it { is_expected.to have_no_content('Unverified') }
      end
    end
  end

  context 'with reject/refuse reasons' do
    let(:claim) { create(:allocated_claim) }

    context 'when the claim was created after messaging feature released' do
      context 'with rejected claims' do
        let(:reason_code) { %w[no_amend_rep_order other] }

        before do
          claim.reject!(reason_code:, reason_text: 'rejecting because...')
          assign(:message, claim.messages.build)
          assign(:claim, claim.reload)
          render
        end

        it { is_expected.to have_no_content(/Reason(s) provided:/) }
        it { is_expected.to have_no_css('li', text: 'No amending representation order') }
        it { is_expected.to have_no_css('li', text: 'Other (rejecting because...)') }
      end
    end

    context 'when the claim was created before messaging feature released' do
      let(:reason_code) { %w[no_amend_rep_order] }

      before do |example|
        travel_to(Settings.reject_refuse_messaging_released_at - 1) do
          claim.reject!(reason_code:, reason_text: 'rejecting because...')
        end

        if example.metadata[:legacy]
          allow_any_instance_of(ClaimStateTransition).to receive(:reason_code).and_return('wrong_case_no')
        end

        assign(:message, claim.messages.build)
        assign(:claim, claim)
        render
      end

      it { is_expected.to have_css('strong.govuk-tag.app-tag--rejected', text: 'Rejected') }
      it { is_expected.to have_content('Reason provided:') }
      it { is_expected.to have_css('li', text: 'No amending representation order') }

      context 'with multiple reasons' do
        let(:reason_code) { %w[no_amend_rep_order case_still_live other] }

        it { is_expected.to have_content('Reasons provided:') }
        it { is_expected.to have_css('li', text: 'No amending representation order') }
        it { is_expected.to have_css('li', text: 'Case still live') }
        it { is_expected.to have_css('li', text: 'Other (rejecting because...)') }
      end

      context 'with legacy cases with non-array reason codes', :legacy do
        it { is_expected.to have_css('li', text: 'Incorrect case number') }
      end
    end
  end

  context 'with injection errors' do
    before do
      claim = certified_claim
      assign(:claim, claim)
      create(:injection_attempt, :with_errors, claim:)
      render
    end

    it { is_expected.to have_css('div.govuk-error-summary') }

    it {
      is_expected.to have_css('ul.govuk-list.govuk-error-summary__list > li > a', text: /injection error/, count: 2)
    }
  end

  context 'with fee injection warnings' do
    before do
      claim = trial_claim
      assign(:claim, claim)
      create(:injection_attempt, claim:)
      create(:misc_fee, fee_type:, claim:, quantity: 1, amount: 100.00)
      render
    end

    context 'with CLAR fees' do
      let(:fee_type) { build(:misc_fee_type, :miumu) }

      it { is_expected.to have_css('div.js-callout-injection-warning') }
      it { is_expected.to have_text('Warning: Paper heavy case or unused materials fees were not injected') }
    end

    context 'with CAV fees' do
      let(:fee_type) { build(:misc_fee_type, :bacav) }

      it { is_expected.to have_css('div.js-callout-injection-warning') }
      it { is_expected.to have_text('Warning: Conferences and views were not injected') }
    end

    context 'with Additional Prep fee' do
      let(:fee_type) { build(:misc_fee_type, :miapf) }

      it { is_expected.to have_css('div.js-callout-injection-warning') }
      it { is_expected.to have_text('Warning: Additional preparation fee was not injected') }
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
    let(:expense) { create(:expense, :with_date_attended, claim:) }

    before do
      create(:date_attended, attended_item: expense)
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
    claim = create(:allocated_claim, external_user: eu)
    claim.certification&.destroy
    certification_type = create(:certification_type, name: 'which ever reason i please')
    create(:certification, claim: claim, certified_by: 'Bobby Legrand', certification_type:)
    case_worker.claims << claim
    claim.reload
    @message = claim.messages.build
    claim
  end

  def trial_claim(trial_prefix = nil)
    claim = create(:submitted_claim, case_type: create(:case_type, :"#{trial_prefix}trial"),
                                     evidence_checklist_ids: [1, 9])
    case_worker.claims << claim
    create(:document, claim_id: claim.id, form_id: claim.form_id)
    @message = claim.messages.build
    claim
  end
end
