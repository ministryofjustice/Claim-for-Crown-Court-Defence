require 'rails_helper'

RSpec.describe Advocate, type: :model do
  it { should belong_to(:chamber) }
  it { should have_many(:claims) }
  it { should have_many(:claims_created) }
  it { should have_many(:documents) }
  it { should have_one(:user) }

  it { should validate_presence_of(:chamber) }
  it { should validate_presence_of(:user) }

  it { should accept_nested_attributes_for(:user) }

  it { should delegate_method(:email).to(:user) }
  it { should delegate_method(:first_name).to(:user) }
  it { should delegate_method(:last_name).to(:user) }
  it { should delegate_method(:name).to(:user) }

  it { should validate_inclusion_of(:role).in_array(%w( admin advocate )) }

  describe 'ROLES' do
    it 'should have "admin" and "advocate"' do
      expect(Advocate::ROLES).to match_array(%w( admin advocate ))
    end
  end

  describe '.admins' do
    before do
      create(:advocate, :admin)
      create(:advocate)
    end

    it 'only returns advocates with role "admin"' do
      expect(Advocate.admins.count).to eq(1)
    end
  end

  describe '.advocates' do
    before do
      create(:advocate, :admin)
      create(:advocate, :admin)
      create(:advocate)
    end

    it 'only returns advocates with role "advocate"' do
      expect(Advocate.advocates.count).to eq(1)
    end
  end

  describe 'roles' do
    let(:admin) { create(:advocate, :admin) }
    let(:advocate) { create(:advocate) }

    describe '#is?' do
      context 'given advocate' do
        context 'if advocate' do
          it 'returns true' do
            expect(advocate.is? :advocate).to eq(true)
          end
        end

        context 'for an admin' do
          it 'returns false' do
            expect(admin.is? :advocate).to eq(false)
          end
        end
      end

      context 'given admin' do
        context 'for an admin' do
          it 'returns true' do
            expect(admin.is? :admin).to eq(true)
          end
        end

        context 'for a advocate' do
          it 'returns false' do
            expect(advocate.is? :admin).to eq(false)
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

      context 'for an admin' do
        it 'returns false' do
          expect(admin.advocate?).to eq(false)
        end
      end
    end

    describe '#admin?' do
      context 'for an admin' do
        it 'returns true' do
          expect(admin.admin?).to eq(true)
        end
      end

      context 'for a advocate' do
        it 'returns false' do
          expect(advocate.admin?).to eq(false)
        end
      end
    end
  end
end
