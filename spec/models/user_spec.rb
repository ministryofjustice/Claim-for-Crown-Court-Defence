require 'rails_helper'

RSpec.describe User, type: :model do
  it { should belong_to(:chamber).conditions(role: 'advocate') }
  it { should have_many(:claims_created) }
  it { should have_many(:case_worker_claims) }
  it { should have_many(:claims_to_manage) }

  it { should validate_presence_of(:role) }
  it { should validate_inclusion_of(:role).in_array(%w( admin advocate case_worker )) }

  describe 'ROLES' do
    it 'should have "advocate" and "case_worker"' do
      expect(User::ROLES).to match_array(%w( admin advocate case_worker ))
    end
  end

  describe '.admin' do
    before do
      create(:admin)
      create(:advocate)
      create(:case_worker)
    end

    it 'only returns users with role "admin"' do
      expect(User.admin.count).to eq(1)
    end
  end

  describe '.advocates' do
    before do
      create(:advocate)
      create(:advocate)
      create(:case_worker)
    end

    it 'only returns users with role "advocate"' do
      expect(User.advocates.count).to eq(2)
    end
  end

  describe '.case_workers' do
    before do
      create(:advocate)
      create(:advocate)
      create(:case_worker)
    end

    it 'only returns users with role "case_worker"' do
      expect(User.case_workers.count).to eq(1)
    end
  end

  describe 'roles' do
    let(:advocate) { create(:advocate) }
    let(:case_worker) { create(:case_worker) }
    let(:admin) { create(:admin) }

    describe '#is?' do
      context 'given advocate' do
        context 'for an advocate' do
          it 'returns true' do
            expect(advocate.is? :advocate).to eq(true)
          end
        end

        context 'for a case worker' do
          it 'returns false' do
            expect(case_worker.is? :advocate).to eq(false)
          end
        end

        context 'for an admin' do
          it 'returns false' do
            expect(admin.is? :advocate).to eq(false)
          end
        end
      end

      context 'given case worker' do
        context 'if case worker' do
          it 'returns true' do
            expect(case_worker.is? :case_worker).to eq(true)
          end
        end

        context 'for an advocate' do
          it 'returns false' do
            expect(advocate.is? :case_worker).to eq(false)
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

        context 'for an advocate' do
          it 'returns false' do
            expect(advocate.is? :admin).to eq(false)
          end
        end

        context 'for a case worker' do
          it 'returns false' do
            expect(case_worker.is? :admin).to eq(false)
          end
        end
      end
    end

    describe '#advocate?' do
      context 'for an advocate' do
        it 'returns true' do
          expect(advocate.advocate?).to eq(true)
        end
      end

      context 'for a case worker' do
        it 'returns false' do
          expect(case_worker.advocate?).to eq(false)
        end
      end

      context 'for an admin' do
        it 'returns false' do
          expect(admin.advocate?).to eq(false)
        end
      end
    end

    describe '#case_worker?' do
      context 'for an case_worker' do
        it 'returns true' do
          expect(case_worker.case_worker?).to eq(true)
        end
      end

      context 'for an advocate' do
        it 'returns false' do
          expect(advocate.case_worker?).to eq(false)
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

      context 'for an advocate' do
        it 'returns false' do
          expect(advocate.admin?).to eq(false)
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
