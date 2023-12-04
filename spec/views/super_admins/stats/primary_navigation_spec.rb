require 'rails_helper'

describe 'layouts/_primary_navigation.html.haml' do
  before do
    super_admin = create(:super_admin)
    initialize_view_helpers(view)
    sign_in(super_admin.user, scope: :user)
    allow(view).to receive(:current_user_persona_is?).and_return(false)

    render
  end

  it 'contains a link to the correct page' do
    expect(rendered).to have_link(
      'Stats',
      href: super_admins_stats_path
    )
  end
end
