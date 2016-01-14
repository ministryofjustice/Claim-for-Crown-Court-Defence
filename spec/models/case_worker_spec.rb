# == Schema Information
#
# Table name: case_workers
#
#  id             :integer          not null, primary key
#  roles          :string
#  created_at     :datetime
#  updated_at     :datetime
#  location_id    :integer
#  days_worked    :string
#

require 'rails_helper'

RSpec.describe CaseWorker, type: :model do
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

  context 'roles' do
    it 'is not valid when no roles present' do
      external_user = build(:case_worker, roles: [])
      expect(external_user).to_not be_valid
      expect(external_user.errors[:roles]).to include('at least one role must be present')
    end

    it 'is not valid for roles not in the ROLES array' do
      external_user = build(:case_worker, roles: ['foobar', 'admin', 'case_worker'])
      expect(external_user).to_not be_valid
      expect(external_user.errors[:roles]).to include('must be one or more of: admin, case worker')
    end

    it 'is valid for roles in the ROLES array' do
      external_user = build(:case_worker, roles: ['case_worker', 'admin'])
      expect(external_user).to be_valid
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


  describe '.admins' do
    before do
      create(:case_worker, :admin)
      create(:case_worker)
    end

    it 'only returns case workers with role "admin"' do
      expect(CaseWorker.admins.count).to eq(1)
    end

    it 'returns case workers with role "admin" and "case_worker"' do
      c = CaseWorker.first
      c.roles = ['admin', 'case_worker']
      c.save!
      expect(CaseWorker.admins.count).to eq(1)
    end
  end

  describe '.case_workers' do
    before do
      create(:case_worker, :admin)
      create(:case_worker, :admin)
      create(:case_worker)
    end

    it 'only returns case workers with role "case_worker"' do
      expect(CaseWorker.case_workers.count).to eq(1)
    end

    it 'returns external_users with role "admin" and "case_worker"' do
      c = CaseWorker.last
      c.roles = ['admin', 'case_worker']
      c.save!
      expect(CaseWorker.case_workers.count).to eq(1)
    end
  end

  describe 'roles' do
    let(:admin) { create(:case_worker, :admin) }
    let(:case_worker) { create(:case_worker) }

    describe '#is?' do
      context 'given case worker' do
        context 'if case worker' do
          it 'returns true' do
            expect(case_worker.is? :case_worker).to eq(true)
          end
        end

        context 'for an admin' do
          it 'returns false' do
            expect(admin.is? :case_worker).to eq(false)
          end
        end
      end

      context 'given admin' do
        context 'for an admin' do
          it 'returns true' do
            expect(admin.is? :admin).to eq(true)
          end
        end

        context 'for a case worker' do
          it 'returns false' do
            expect(case_worker.is? :admin).to eq(false)
          end
        end
      end
    end

    describe '#case_worker?' do
      context 'for a case_worker' do
        it 'returns true' do
          expect(case_worker.case_worker?).to eq(true)
        end
      end

      context 'for an admin' do
        it 'returns false' do
          expect(admin.case_worker?).to eq(false)
        end
      end
    end

    describe '#admin?' do
      context 'for an admin' do
        it 'returns true' do
          expect(admin.admin?).to eq(true)
        end
      end

      context 'for a case worker' do
        it 'returns false' do
          expect(case_worker.admin?).to eq(false)
        end
      end
    end
  end
end
