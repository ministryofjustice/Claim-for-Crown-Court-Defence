require 'rails_helper'

RSpec.describe 'external_users/claims/show.html.haml' do
  before(:all) do
    @external_user = create(:external_user, :litigator_and_admin)
  end

  after(:all) do
    clean_database
  end

  before do
    initialize_view_helpers(view)
    sign_in(@external_user.user, scope: :user)
    allow(view).to receive(:current_user_persona_is?).and_return(false)
  end

  context 'for AGFS claims' do
    describe 'document checklist' do
      let(:claim) { create(:claim, evidence_checklist_ids: [1, 9]) }

      before do
        assign(:claim, claim)
        assign(:messages, claim.messages.most_recent_last)
        assign(:message, claim.messages.build)
      end

      it 'displays the documents that have been uploaded' do
        render
        expect(rendered).to have_css('li', text: 'Representation order')
        expect(rendered).to have_css('li', text: 'Justification for out of time claim')
      end

      it 'does not display a `download all` link' do
        render
        expect(rendered).to_not have_link('Download all')
      end
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

  context 'for LGFS claims' do
    let(:claim) { create(:litigator_claim) }

    before do
      assign(:claim, claim)
      assign(:messages, claim.messages.most_recent_last)
      assign(:message, claim.messages.build)
    end

    describe 'basic claim information' do
      it 'doesn\'t display the litigator category section' do
        render
        expect(rendered).to have_no_css('div', text: 'Advocate category')
        expect(rendered).to have_no_css('div', text: 'Litigator category')
      end

      it 'displays the litigator account number section' do
        render
        expect(rendered).to have_css('div', text: 'Litigator account number')
      end
    end

    describe 'Fees, expenses and more information' do
      context 'when travel expenses have been calculated' do
        let!(:expense) { create(:expense, :with_calculated_distance_increased, mileage_rate_id: 2, location: 'Basildon', date: 3.days.ago, claim:) }

        it 'does not render state labels' do
          claim.reload
          render
          expect(rendered).to_not have_css('strong.govuk-tag.app-tag--unverified', text: 'Unverified')
        end
      end
    end
  end

  context 'Interim claims' do
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

      context 'Effective PCMH' do
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
