require 'rails_helper'

RSpec.describe UserMessageStatusesController, type: :controller do
  describe 'GET #index' do
    let(:advocate) { create(:advocate) }

    before do
      create(:message)
      sign_in advocate.user
      get :index
    end

    it 'assigns @user_message_statuses for the current user' do
      expect(assigns(:user_message_statuses)).to eq(UserMessageStatus.for(advocate.user).not_marked_as_read)
    end

    it 'renders the index template' do
      expect(response).to render_template(:index)
    end

    render_views

    it 'renders breadcrumbs' do
      expect(response.body).to match(/Dashboard.*Messages/)
    end
  end

  describe 'PUT #update' do
    let(:advocate) { create(:advocate) }
    let(:message) { create(:message) }

    before do
      create(:message)
      sign_in advocate.user
      request.env['HTTP_REFERER'] = 'redirect-to-page'
      put :update, id: message.user_message_statuses.first
    end

    it 'marks the message as read' do
      expect(message.user_message_statuses.first).to be_read
    end
  end
end
