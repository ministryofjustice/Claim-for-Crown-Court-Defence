# == Schema Information
#
# Table name: case_workers
#
#  id         :integer          not null, primary key
#  role       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe CaseWorker, type: :model do
  it { should have_one(:user) }
  it { should have_many(:case_worker_claims) }
  it { should have_many(:claims) }

  it { should delegate_method(:email).to(:user) }
  it { should delegate_method(:first_name).to(:user) }
  it { should delegate_method(:last_name).to(:user) }
  it { should delegate_method(:name).to(:user) }

  it { should accept_nested_attributes_for(:user) }

  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:role) }
  it { should validate_inclusion_of(:role).in_array(%w( admin case_worker )) }

  describe 'ROLES' do
    it 'should have "admin" and "case_worker"' do
      expect(CaseWorker::ROLES).to match_array(%w( admin case_worker ))
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
