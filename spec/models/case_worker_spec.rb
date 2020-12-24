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

RSpec.describe CaseWorker, type: :model do
  include DatabaseHousekeeping
  it_behaves_like 'roles', CaseWorker, CaseWorker::ROLES

  it { should belong_to(:location) }
  it { should have_one(:user) }
  it { should have_many(:case_worker_claims) }
  it { should have_many(:claims) }

  it { should delegate_method(:email).to(:user) }
  it { should delegate_method(:first_name).to(:user) }
  it { should delegate_method(:last_name).to(:user) }
  it { should delegate_method(:name).to(:user) }

  it { should accept_nested_attributes_for(:user) }

  it { should validate_presence_of(:location).with_message('Location cannot be blank') }
  it { should validate_presence_of(:user).with_message('User cannot be blank') }

  describe 'ROLES' do
    it 'should have "admin", "case_worker" and "provider_management"' do
      expect(CaseWorker::ROLES).to match_array(%w(admin case_worker provider_management))
    end
  end

  context 'soft deletion scopes' do
    before(:all) do
      @location_1 = create :location
      @location_2 = create :location
      @live_cw1 = create :case_worker, location: @location_1
      @live_cw2 = create :case_worker, location: @location_2
      @dead_cw1 = create :case_worker, :softly_deleted, location: @location_1
      @dead_cw2 = create :case_worker, :softly_deleted, location: @location_2
    end

    after(:all) { clean_database }

    describe 'active scope' do
      it 'should only return undeleted records' do
        expect(CaseWorker.active.order(:id)).to eq([@live_cw1, @live_cw2])
      end

      it 'should return ActiveRecord::RecordNotFound if find by id relates to a deleted record' do
        expect {
          CaseWorker.active.find(@dead_cw1.id)
        }.to raise_error ActiveRecord::RecordNotFound, %Q{Couldn't find CaseWorker with 'id'=#{@dead_cw1.id} [WHERE "case_workers"."deleted_at" IS NULL]}
      end

      it 'returns an empty array if the selection criteria only reference deleted records' do
        expect(CaseWorker.active.where(id: [@dead_cw1.id, @dead_cw2.id])).to be_empty
      end
    end

    describe 'deleted scope' do
      it 'should return only deleted records' do
        expect(CaseWorker.softly_deleted.order(:id)).to eq([@dead_cw1, @dead_cw2])
      end

      it 'should return ActiveRecord::RecordNotFound if find by id relates to an undeleted record' do
        expect(CaseWorker.find(@live_cw1.id)).to eq(@live_cw1)
        expect {
          CaseWorker.softly_deleted.find(@live_cw1.id)
        }.to raise_error ActiveRecord::RecordNotFound, /Couldn't find CaseWorker with 'id'=#{@live_cw1.id}/
      end

      it 'returns an empty array if the selection criteria only reference live records' do
        expect(CaseWorker.softly_deleted.where(id: [@live_cw1.id, @live_cw2.id])).to be_empty
      end
    end

    describe 'default scope' do
      it 'should return deleted and undeleted records' do
        expect(CaseWorker.order(:id)).to eq([@live_cw1, @live_cw2, @dead_cw1, @dead_cw2])
      end

      it 'should return the record if find by id relates to a deleted record' do
        expect(CaseWorker.find(@dead_cw1.id)).to eq @dead_cw1
      end

      it 'returns the deleted records if the selection criteria reference only deleted records' do
        expect(CaseWorker.where(id: [@dead_cw1.id, @dead_cw2.id]).order(:id)).to eq([@dead_cw1, @dead_cw2])
      end
    end
  end

  describe 'soft_delete' do
    it 'should set deleted at on the caseworker and user records' do
      cw = create :case_worker
      user = cw.user
      cw.soft_delete
      expect(cw.reload.deleted_at).not_to be_nil
      expect(user.reload.deleted_at).not_to be_nil
    end
  end

  describe '#active?' do
    it 'returns false for deleted records' do
      cw = build :case_worker, :softly_deleted
      expect(cw.active?).to be false
    end

    it 'returns true for active records' do
      cw = build :case_worker
      expect(cw.active?).to be true
    end
  end
end
