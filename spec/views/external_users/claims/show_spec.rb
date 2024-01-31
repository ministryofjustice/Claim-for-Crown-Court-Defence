require 'rails_helper'

RSpec.describe 'external_users/claims/show.html.haml' do
  let(:external_user) { create(:external_user, :litigator_and_admin) }

  before do
    initialize_view_helpers(view)
    sign_in(external_user.user, scope: :user)
    allow(view).to receive(:current_user_persona_is?).and_return(false)
  end

  context 'with an AGFS claims' do
    describe 'document checklist' do
      let(:claim) { create(:claim, evidence_checklist_ids: [1, 9]) }

      before do
        assign(:claim, claim)
        assign(:messages, claim.messages.most_recent_last)
        assign(:message, claim.messages.build)
        render
      end

      it { expect(rendered).to have_css('li', text: 'Representation order') }
      it { expect(rendered).to have_css('li', text: 'Justification for out of time claim') }
      it { expect(rendered).to have_no_link('Download all') }
    end

    describe 'basic claim information' do
      let(:claim) { create(:claim, evidence_checklist_ids: [1, 9]) }

      before do
        assign(:claim, claim)
        assign(:messages, claim.messages.most_recent_last)
        assign(:message, claim.messages.build)
      end

      it 'displays the advocate category section' do
        render
        expect(rendered).to have_css('div', text: 'Advocate category')
      end

      it 'displays the advocate account number section' do
        render
        expect(rendered).to have_css('div', text: 'Advocate account number')
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
  end

  context 'with an LGFS claims' do
    let(:claim) { create(:litigator_claim) }

    before do
      assign(:claim, claim)
      assign(:messages, claim.messages.most_recent_last)
      assign(:message, claim.messages.build)
    end

    describe 'basic claim information' do
      before { render }

      it { expect(rendered).to have_no_css('div', text: 'Advocate category') }
      it { expect(rendered).to have_no_css('div', text: 'Litigator category') }
      it { expect(rendered).to have_css('div', text: 'Litigator account number') }
    end

    describe 'Fees, expenses and more information' do
      context 'when travel expenses have been calculated' do
        before do
          create(
            :expense, :with_calculated_distance_increased,
            mileage_rate_id: 2,
            location: 'Basildon',
            date: 3.days.ago,
            claim:
          )
        end

        it 'does not render state labels' do
          claim.reload
          render
          expect(rendered).to have_no_css('strong.govuk-tag.app-tag--unverified', text: 'Unverified')
        end
      end
    end
  end

  context 'with an interim claims' do
    let(:claim) { create(:interim_claim, :interim_effective_pcmh_fee) }

    before do
      assign(:claim, claim)
      assign(:messages, claim.messages.most_recent_last)
      assign(:message, claim.messages.build)
    end

    describe 'basic claim information' do
      it 'displays the fee type section' do
        render
        expect(rendered).to have_css('div', text: 'Fee type')
      end

      context 'with an effective PCMH' do
        it 'displays the PPE total section' do
          render
          expect(rendered).to have_css('div', text: 'PPE total at the time')
        end

        it 'displays the Effective PCMH section' do
          render
          expect(rendered).to have_css('div', text: 'Effective PCMH')
        end
      end
    end

    describe 'Fees, expenses and more information' do
      it 'does not show the expenses section' do
        render
        expect(rendered).to have_no_css('p', text: 'There are no expenses for this claim')
      end
    end
  end
end
