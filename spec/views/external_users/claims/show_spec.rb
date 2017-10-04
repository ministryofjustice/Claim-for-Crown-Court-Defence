require 'rails_helper'

describe 'external_users/claims/show.html.haml', type: :view do

  include ViewSpecHelper

  before(:all) do
    @external_user = create(:external_user, :litigator_and_admin)
  end

  after(:all) do
    clean_database
  end

  before(:each) do
    initialize_view_helpers(view)
    sign_in :user, @external_user.user
    allow(view).to receive(:current_user_persona_is?).and_return(false)
    render
  end

  context 'for AGFS claims' do
    before(:all) do
      @claim = create :claim, evidence_checklist_ids: [1, 9]
      @messages = @claim.messages.most_recent_last
      @message  = @claim.messages.build
    end

    describe 'document checklist' do
      it 'displays the documents that have been uploaded' do
        expect(rendered).to have_selector('li', text: 'Representation order')
        expect(rendered).to have_selector('li', text: 'Justification for out of time claim')
      end

      it 'does not display a `download all` link' do
        expect(rendered).to_not have_link('Download all')
      end
    end

    describe 'basic claim information' do
      it 'displays the advocate category section' do
        expect(rendered).to have_selector('div', text: 'Advocate category')
      end

      it 'displays the advocate account number section' do
        expect(rendered).to have_selector('div', text: 'Advocate account number')
      end
    end
  end

  context 'for LGFS claims' do
    before(:all) do
      @claim = create :litigator_claim
      @messages = @claim.messages.most_recent_last
      @message  = @claim.messages.build
    end

    describe 'basic claim information' do
      it 'doesn\'t display the litigator category section' do
        expect(rendered).not_to have_selector('div', text: 'Advocate category')
        expect(rendered).not_to have_selector('div', text: 'Litigator category')
      end

      it 'displays the litigator account number section' do
        expect(rendered).to have_selector('div', text: 'Litigator account number')
      end
    end
  end

  context 'Interim claims' do
    before(:all) do
      @claim = create(:interim_claim, :interim_effective_pcmh_fee)
      @messages = @claim.messages.most_recent_last
      @message  = @claim.messages.build
    end

    describe 'basic claim information' do
      it 'displays the fee type section' do
        expect(rendered).to have_selector('div', text: 'Fee type')
      end

      context 'Effective PCMH' do
        it 'displays the PPE total section' do
          expect(rendered).to have_selector('div', text: 'PPE total at the time')
        end

        it 'displays the Effective PCMH section' do
          expect(rendered).to have_selector('div', text: 'Effective PCMH')
        end
      end
    end

    describe 'Fees, expenses and more information' do
      it 'should not show the expenses section' do
        expect(rendered).not_to have_selector('p', text: 'There are no expenses for this claim')
      end
    end
  end
end
