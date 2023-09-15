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

RSpec.describe CaseWorker do
  include DatabaseHousekeeping
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
      expect(CaseWorker::ROLES).to match_array(%w[admin case_worker provider_management])
    end
  end

  context 'with live and softly deleted users' do
    let(:first_location) { create(:location) }
    let(:second_location) { create(:location) }
    let!(:live_users) do
      [
        create(:case_worker, location: first_location),
        create(:case_worker, location: second_location)
      ]
    end
    let!(:dead_users) do
      [
        create(:case_worker, :softly_deleted, location: first_location),
        create(:case_worker, :softly_deleted, location: second_location)
      ]
    end

    context 'with the active scope' do
      subject(:records) { described_class.active }

      it { is_expected.to match_array(live_users) }
      it { expect { records.find(dead_users.first.id) }.to raise_error ActiveRecord::RecordNotFound }
      it { expect(records.where(id: dead_users.map(&:id))).to be_empty }
    end

    context 'with the softly deleted scope' do
      subject(:records) { described_class.softly_deleted }

      it { is_expected.to match_array(dead_users) }
      it { expect { records.find(live_users.first.id) }.to raise_error ActiveRecord::RecordNotFound }
      it { expect(records.where(id: live_users.map(&:id))).to be_empty }
    end

    context 'with the default scope' do
      subject(:records) { described_class.all }

      it { is_expected.to match_array(live_users + dead_users) }
      it { expect(records.find(dead_users.first.id)).to eq dead_users.first }
      it { expect(records.where(id: dead_users.map(&:id))).to match_array(dead_users) }
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
