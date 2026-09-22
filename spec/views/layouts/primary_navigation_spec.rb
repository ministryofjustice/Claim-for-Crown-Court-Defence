require 'rails_helper'

describe 'layouts/_primary_navigation.html.haml' do
  let(:active_navigation_links) do
    Capybara.string(rendered).all('li.govuk-service-navigation__item--active a').map(&:text)
  end

  before do
    initialize_view_helpers(view)
    allow(view).to receive(:current_user_persona_is?).and_return(false)
  end

  context 'when the current user is a super admin' do
    before do
      super_admin = create(:super_admin)
      sign_in(super_admin.user, scope: :user)
      render
    end

    it 'contains a link to the correct page' do
      expect(rendered).to have_link(
        'Stats',
        href: super_admins_stats_path
      )
    end
  end

  context 'when the current user is a case worker admin' do
    let(:case_worker) { create(:case_worker, :admin) }
    let(:controller_name) { 'case_workers/admin/allocations' }
    let(:tab) { nil }

    before do
      sign_in(case_worker.user, scope: :user)
      request.path = case_workers_admin_allocations_path
      allow(view).to receive(:params).and_return(ActionController::Parameters.new(controller: controller_name, tab:))
      render
    end

    context 'when on the default allocation page' do
      it 'marks only Allocation as active' do
        expect(active_navigation_links).to contain_exactly('Allocation')
      end
    end

    context 'when on the explicit allocation tab' do
      let(:tab) { 'unallocated' }

      it 'marks only Allocation as active' do
        expect(active_navigation_links).to contain_exactly('Allocation')
      end
    end

    context 'when on the re-allocation tab' do
      let(:tab) { 'allocated' }

      it 'marks only Re-allocation as active' do
        expect(active_navigation_links).to contain_exactly('Re-allocation')
      end
    end

    context 'when on another page with an allocation tab param' do
      let(:controller_name) { 'case_workers/admin/case_workers' }
      let(:tab) { 'allocated' }

      before do
        request.path = case_workers_admin_case_workers_path
      end

      it 'does not mark an allocation nav item as active' do
        expect(active_navigation_links).to be_empty
      end
    end
  end
end
