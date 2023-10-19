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
      href: super_admins_stats_path)
  end
end

describe 'super_admins/stats/show.html.haml' do

  before do
    super_admin = create(:super_admin)
    initialize_view_helpers(view)
    sign_in(super_admin.user, scope: :user)
    allow(view).to receive(:current_user_persona_is?).and_return(false)
    render
  end

  it 'includes two half-width columns' do
    expect(rendered).to have_css('div', class: 'govuk-grid-column-one-half').twice
  end

  it 'includes one full-width column' do
    expect(rendered).to have_css('div', class: 'govuk-grid-column-full')
  end

  it 'includes a total claims chart' do
    expect(rendered).to have_css('div', id: 'total-claims-chart')
  end

  it 'includes a total claims value chart' do
    expect(rendered).to have_css('div', id: 'total-claim-values-chart')
  end

  it 'includes a 6 month breakdown chart' do
    expect(rendered).to have_css('div', id: 'six-month-chart')
  end

  it 'does not show an error message with default or correct dates' do
    assign(:date_err, false)
    render
    expect(rendered).not_to have_css('div', class: 'govuk-notification-banner')
  end

  it 'shows an error message when invalid dates are displayed' do
    assign(:date_err, true)
    render
    expect(rendered).to have_css('div', class: 'govuk-notification-banner')
  end

end
