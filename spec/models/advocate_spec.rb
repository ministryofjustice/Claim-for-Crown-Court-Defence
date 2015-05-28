require 'rails_helper'

RSpec.describe Advocate, type: :model do
  it { should belong_to(:chamber) }
  it { should have_many(:claims) }
  it { should have_many(:documents) }
  it { should have_one(:user) }

  it { should validate_presence_of(:chamber) }
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:user) }

  it { should accept_nested_attributes_for(:user) }

  it { should delegate_method(:email).to(:user) }

  it { should validate_inclusion_of(:role).in_array(%w( admin advocate )) }

  it { should validate_presence_of(:account_number) }


  context 'account number validation' do
    
    it 'should fail validation if too long' do
      a = FactoryGirl.build :advocate, account_number: 'ACC123'
      expect(a).not_to be_valid
      expect(a.errors[:account_number]).to eq( ['must be 5 alhpa-numeric characters'] )
    end

    it 'should fail validation if too short' do
      a = FactoryGirl.build :advocate, account_number: 'AC12'
      expect(a).not_to be_valid
      expect(a.errors[:account_number]).to eq( ['must be 5 alhpa-numeric characters'] )
    end

    it 'should fail validation if not alpha-numeric' do
      a = FactoryGirl.build :advocate, account_number: 'AC-123'
      expect(a).not_to be_valid
      expect(a.errors[:account_number]).to eq( ['must be 5 alhpa-numeric characters'] )
    end

    it 'should pass validation if 5 alpha-numeric' do
      a = FactoryGirl.build :advocate, account_number: 'AC123'
      expect(a).to be_valid
    end
  end


  describe '#name' do
    subject { create(:advocate) }

    it 'returns the first and last names' do
      expect(subject.name).to eq("#{subject.first_name} #{subject.last_name}")
    end
  end

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
