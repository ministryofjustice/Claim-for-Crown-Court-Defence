require 'rails_helper'

RSpec.describe 'layouts/_user' do
  let(:user) do
    create(:external_user, user: build(:user, first_name: 'Alex', last_name: 'Smith', multi_firm_user: true)).user
  end

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

  it 'hides account switching when the primary account turns multi-firm access off' do
    view.request.session[:multi_firm_primary_user_id] = user.id
    user.update!(multi_firm_user: false)

    render

    expect(rendered).not_to include('Switch account')
  end

  it 'hides account switching when the primary account no longer exists' do
    view.request.session[:multi_firm_primary_user_id] = -1

    render

    expect(rendered).not_to include('Switch account')
  end

  it 'shows account switching from a linked account while the primary has multi-firm access enabled' do
    link = create(:multi_firm_user_link, user:)
    view.request.session[:multi_firm_primary_user_id] = user.id
    allow(view).to receive(:current_user).and_return(link.linked_user)

    render

    expect(rendered).to include('Switch account')
  end
end
