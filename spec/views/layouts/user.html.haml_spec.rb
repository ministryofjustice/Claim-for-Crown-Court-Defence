require 'rails_helper'

RSpec.describe 'layouts/_user' do
  let(:user) { build_stubbed(:user, first_name: 'Alex', last_name: 'Smith') }

  before do
    allow(view).to receive(:current_user).and_return(user)
    view.define_singleton_method(:signed_in_user_profile_path) { '/profile' }
  end

  context 'when there is a multi-firm session' do
    before do
      view.request.session[:multi_firm_primary_user_id] = user.id
      render
    end

    let(:profile_position) { rendered.index('Alex Smith') }
    let(:switch_position) { rendered.index('Switch account') }
    let(:sign_out_position) { rendered.index('Sign out') }

    it 'shows account switching after the user name' do
      expect(profile_position).to be < switch_position
    end

    it 'shows account switching before sign out' do
      expect(switch_position).to be < sign_out_position
    end
  end

  it 'hides account switching outside a multi-firm session' do
    render

    expect(rendered).not_to include('Switch account')
  end
end
