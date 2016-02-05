# == Schema Information
#
# Table name: case_workers
#
#  id          :integer          not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  location_id :integer
#  days_worked :string
#  roles       :string
#

require 'rails_helper'

RSpec.describe CaseWorker, type: :model do
  it_behaves_like 'user_roles', CaseWorker, CaseWorker::ROLES

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

  context 'validations' do
    context 'days_worked' do
      let(:cw)         { FactoryGirl.build :case_worker }

      it 'should validate 11111' do
        expect(cw).to be_valid
      end

      it 'should validate 10111' do
        cw.days_worked = [1, 0, 1, 1, 1]
        expect(cw).to be_valid
      end

      it 'should reject if not 5 days' do
        cw.days_worked = [ 0, 1, 1 ]
        expect(cw).not_to be_valid
        expect(cw.errors.full_messages).to eq [ "Days worked invalid" ]
      end

      it 'should reject if not 1s and zeros' do
        cw.days_worked = [ 0, 1, 1, 'F', 1 ]
        expect(cw).not_to be_valid
        expect(cw.errors.full_messages).to eq [ "Days worked invalid" ]
      end

      it 'should reject all days as non working days' do
        cw.days_worked = [ 0, 0, 0, 0, 0]
        expect(cw).not_to be_valid
        expect(cw.errors.full_messages).to eq [ "At least one day must be specified as a working day"]
      end
    end
  end
end
