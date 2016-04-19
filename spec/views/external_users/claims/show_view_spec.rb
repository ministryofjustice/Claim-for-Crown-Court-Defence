require 'rails_helper'

describe 'external_users/claims/show.html.haml', type: :view do

  include ViewSpecHelper

  before(:all) do
    @advocate = create(:external_user, :advocate_and_admin)
    @claim = create :claim, evidence_checklist_ids: [1, 9]
    @messages = @claim.messages.most_recent_last
    @message = @claim.messages.build
  end

  after(:all) do
    clean_database
  end

  before(:each) do
    initialize_view_helpers(view)
    sign_in :user, @advocate.user
    # allow(view).to receive(:current_user_persona_is?).and_return(false)
    assign(:claim, @claim)
    allow(view).to receive(:url_for_edit_external_users_claim).and_return('http://my_edit_external_users_path')
  end

  context 'document checklist' do
    it 'displays the documents that have been uploaded' do
      render
      expect(response.body).to have_selector('li', text: 'Representation order')
      expect(response.body).to have_selector('li', text: 'Justification for out of time claim')
    end
  end

end
