require 'rails_helper'

describe 'external_users/claims/show.html.haml', type: :view do

  include ViewSpecHelper

  before(:all) do
    @advocate = create(:external_user, :advocate_and_admin)
  end

  after(:all) do
    clean_database
  end

  before(:each) do
    initialize_view_helpers(view)
    sign_in :user, @advocate.user
    allow(view).to receive(:url_for_edit_external_users_claim).and_return('http://my_edit_external_users_path')
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
end
