# == Schema Information
#
# Table name: case_workers
#
#  id          :integer          not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  location_id :integer
#  roles       :string
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
    it 'should have "admin" and "case_worker"' do
      expect(CaseWorker::ROLES).to match_array(%w( admin case_worker ))
    end
  end

  context 'soft deletions' do
    before(:all) do
      @location_1 = create :location
      @location_2 = create :location
      @live_cw1 = create :case_worker, location: @location_1
      @live_cw2 = create :case_worker, location: @location_2
      @dead_cw1 = create :case_worker, :softly_deleted, location: @location_1
      @dead_cw2 = create :case_worker, :softly_deleted, location: @location_2
    end

    after(:all) { clean_database }

    describe 'default scope' do
      it 'should only return undeleted records' do
        expect(CaseWorker.all.order(:id)).to eq([ @live_cw1, @live_cw2 ])
      end

      it 'should return ActiveRecord::RecordNotFound if find by id relates to a deleted record' do
        expect{
          CaseWorker.find(@dead_cw1.id)
        }.to raise_error ActiveRecord::RecordNotFound, %Q{Couldn't find CaseWorker with 'id'=#{@dead_cw1.id} [WHERE "case_workers"."deleted_at" IS NULL]}
      end

      it 'returns an empty array if the selection criteria only reference deleted records' do
        expect(CaseWorker.where(id: [@dead_cw1.id, @dead_cw2.id])).to be_empty
      end

    end

    describe 'including_deleted scope' do
      it 'should return deleted and undeleted records' do
        expect(CaseWorker.including_deleted.order(:id)).to eq([ @live_cw1, @live_cw2, @dead_cw1, @dead_cw2])
      end

      it 'should return the record if find by id relates to a deleted record' do
        expect(CaseWorker.including_deleted.find(@dead_cw1.id)).to eq @dead_cw1
      end

      it 'returns the deleted records if the selection criteria reference only deleted records' do
        expect(CaseWorker.including_deleted.where(id: [@dead_cw1.id, @dead_cw2.id]).order(:id)).to eq([@dead_cw1, @dead_cw2])
      end
    end
  end

end
