# frozen_string_literal: true

require Rails.root.join('lib', 'tasks', 'rake_helpers', 'login_method_updater')

RSpec.describe Tasks::RakeHelpers::LoginMethodUpdater do
  subject(:result) { described_class.new('entra', dry_run:).call(csv.path) }

  let(:dry_run) { false }
  let(:csv) { Tempfile.new(['emails', '.csv']) }
  let(:listed_user) { create(:user, email: 'listed@example.com') }
  let(:other_user) { create(:user) }

  before do
    listed_user && other_user
    csv.write(rows.join("\n"))
    csv.close
  end

  after { csv.unlink }

  context 'with a header row, mixed case, whitespace, and an unknown email' do
    let(:rows) { ['email', ' Listed@Example.com ', 'unknown@example.com'] }

    it 'changes only the listed users and reports the rest', :aggregate_failures do
      expect(result).to have_attributes(changed: ['listed@example.com'], unchanged: 0,
                                        not_found: ['unknown@example.com'])
      expect(listed_user.login_route.reload.login_method).to eq('entra')
      expect(other_user.login_route.reload.login_method).to eq('legacy')
    end
  end

  context 'when a listed user already has the login method' do
    let(:rows) { ['listed@example.com'] }

    before { listed_user.login_route.update!(login_method: 'entra') }

    it { is_expected.to have_attributes(changed: [], unchanged: 1, not_found: []) }
  end

  context 'when reverting to legacy' do
    subject(:result) { described_class.new('legacy', dry_run: false).call(csv.path) }

    let(:rows) { ['listed@example.com'] }

    before { listed_user.login_route.update!(login_method: 'entra') }

    it 'changes the login method back', :aggregate_failures do
      expect(result.changed).to eq(['listed@example.com'])
      expect(listed_user.login_route.reload.login_method).to eq('legacy')
    end
  end

  context 'with a dry run' do
    let(:dry_run) { true }
    let(:rows) { ['listed@example.com', 'unknown@example.com'] }

    it 'reports what would change without updating', :aggregate_failures do
      expect(result).to have_attributes(changed: ['listed@example.com'], unchanged: 0,
                                        not_found: ['unknown@example.com'])
      expect(listed_user.login_route.reload.login_method).to eq('legacy')
    end
  end

  context 'without specifying dry_run' do
    subject(:result) { described_class.new('entra').call(csv.path) }

    let(:rows) { ['listed@example.com'] }

    it 'defaults to a dry run', :aggregate_failures do
      expect(result.changed).to eq(['listed@example.com'])
      expect(listed_user.login_route.reload.login_method).to eq('legacy')
    end
  end
end
