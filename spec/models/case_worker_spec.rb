# == Schema Information
#
# Table name: case_workers
#
#  id          :integer          not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  location_id :integer
#  roles       :string
#  deleted_at  :datetime
#  uuid        :uuid
#

require 'rails_helper'
require 'support/shared_examples_for_users'

RSpec.describe CaseWorker do
  it_behaves_like 'roles', described_class, described_class::ROLES

  it { is_expected.to belong_to(:location) }
  it { is_expected.to have_one(:user) }
  it { is_expected.to have_many(:case_worker_claims) }
  it { is_expected.to have_many(:claims) }

  it { is_expected.to delegate_method(:email).to(:user) }
  it { is_expected.to delegate_method(:first_name).to(:user) }
  it { is_expected.to delegate_method(:last_name).to(:user) }
  it { is_expected.to delegate_method(:name).to(:user) }

  it { is_expected.to accept_nested_attributes_for(:user) }

  it { is_expected.to validate_presence_of(:location).with_message('Location cannot be blank') }
  it { is_expected.to validate_presence_of(:user).with_message('User cannot be blank') }

  describe 'ROLES' do
    it 'has "admin", "case_worker" and "provider_management"' do
      expect(described_class::ROLES).to match_array(%w[admin case_worker provider_management beta_tester])
    end
  end

  it_behaves_like 'user model with default, active and softly deleted scopes' do
    let(:first_location) { create(:location) }
    let(:second_location) { create(:location) }
    let(:live_users) do
      [
        create(:case_worker, location: first_location),
        create(:case_worker, location: second_location)
      ]
    end
    let(:dead_users) do
      [
        create(:case_worker, :softly_deleted, location: first_location),
        create(:case_worker, :softly_deleted, location: second_location)
      ]
    end
  end

  describe '#soft_delete' do
    subject(:soft_delete) { case_worker.soft_delete }

    let(:case_worker) { create(:case_worker) }

    it { expect { soft_delete }.to change(case_worker, :deleted_at).from(nil) }
    it { expect { soft_delete }.to change(case_worker.user, :deleted_at).from(nil) }
  end

  describe '#active?' do
    it 'returns false for deleted records' do
      cw = build(:case_worker, :softly_deleted)
      expect(cw.active?).to be false
    end

    it 'returns true for active records' do
      cw = build(:case_worker)
      expect(cw.active?).to be true
    end
  end
end
