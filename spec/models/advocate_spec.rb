# == Schema Information
#
# Table name: advocates
#
#  id              :integer          not null, primary key
#  role            :string
#  provider_id     :integer
#  created_at      :datetime
#  updated_at      :datetime
#  supplier_number :string
#  uuid            :uuid
#

require 'rails_helper'

RSpec.describe Advocate, type: :model do
  it { should belong_to(:provider) }
  it { should have_many(:claims) }
  it { should have_many(:claims_created) }
  it { should have_many(:documents) }
  it { should have_one(:user) }

  it { should validate_presence_of(:provider) }
  it { should validate_presence_of(:user) }

  it { should accept_nested_attributes_for(:user) }

  it { should delegate_method(:email).to(:user) }
  it { should delegate_method(:first_name).to(:user) }
  it { should delegate_method(:last_name).to(:user) }
  it { should delegate_method(:name).to(:user) }

  it { should validate_inclusion_of(:role).in_array(%w( admin advocate )) }

  context 'supplier number validation' do
    context 'when no Provider present' do
      it 'should be valid' do
        a = FactoryGirl.build :advocate
        expect(a).to be_valid
      end
    end

    context 'when Provider present and Provider is a "firm"' do
      let!(:provider) { create(:provider, provider_type: 'firm', supplier_number: 'ZZ123') }

      before do
        subject.provider = provider
      end

      it { should_not validate_presence_of(:supplier_number) }

      it 'should be valid without a supplier number' do
        a = FactoryGirl.build :advocate, provider: provider, supplier_number: nil
        expect(a).to be_valid
      end
    end

    context 'when provider present and Provider is a "chamber"' do
      let(:provider) { create(:provider, provider_type: 'chamber', supplier_number: 'XX123') }

      before do
        subject.provider = provider
      end

      it { should validate_presence_of(:supplier_number) }

      it 'should not be valid without a supplier number' do
        a = FactoryGirl.build :advocate, provider: provider, supplier_number: nil
        expect(a).not_to be_valid
      end

      it 'should fail validation if too long' do
        a = FactoryGirl.build :advocate, supplier_number: 'ACC123', provider: provider
        expect(a).not_to be_valid
        expect(a.errors[:supplier_number]).to eq( ['must be 5 alpha-numeric characters'] )
      end

      it 'should fail validation if too short' do
        a = FactoryGirl.build :advocate, supplier_number: 'AC12', provider: provider
        expect(a).not_to be_valid
        expect(a.errors[:supplier_number]).to eq( ['must be 5 alpha-numeric characters'] )
      end

      it 'should fail validation if not alpha-numeric' do
        a = FactoryGirl.build :advocate, supplier_number: 'AC-12', provider: provider
        expect(a).not_to be_valid
        expect(a.errors[:supplier_number]).to eq( ['must be 5 alpha-numeric characters'] )
      end

      it 'should pass validation if 5 alpha-numeric' do
        a = FactoryGirl.build :advocate, supplier_number: 'AC123', provider: provider
        expect(a).to be_valid
      end
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

  describe '#name_and_number' do
    it 'should print last name, first name and supplier number' do
      a = FactoryGirl.create(:advocate, supplier_number: 'XX878', user: FactoryGirl.create(:user, last_name: 'Smith', first_name: 'John'))
      expect(a.name_and_number).to eq "Smith, John: XX878"
    end
  end

  describe '#advocates_in_provider' do

    it 'should raise and exception if called on a advocate who isnt an admin' do
      advocate = FactoryGirl.create :advocate
      expect {
        advocate.advocates_in_provider
      }.to raise_error RuntimeError, "Cannot call #advocates_in_provider on advocates who are not admins"
    end

    it 'should return a collection of advocates in same provider in alphabetic order' do
      provider1      = FactoryGirl.create :provider
      provider2      = FactoryGirl.create :provider

      admin1_ch1    = create_admin provider1, 'Lucy', 'Zebra'
      advocate1_ch1 = create_advocate provider1, 'Miranda', 'Bison'
      advocate3_ch1 = create_advocate provider1, 'Geoff', 'Elephant'

      admin1_ch2    = create_admin provider2, 'Martin', 'Tiger'
      admin2_ch2    = create_admin provider2, 'Robert', 'Lion'
      advocate1_ch2 = create_advocate provider2, 'Mary', 'Hippo'
      advocate2_ch2 = create_advocate provider2, 'Anna', 'Wildebeest'
      advocate3_ch2 = create_advocate provider2, 'George', 'Meerkat'

      advocates = admin2_ch2.advocates_in_provider
      expect(advocates.map(&:user).map(&:last_name)).to eq ( ["Hippo", "Lion", "Meerkat", "Tiger", "Wildebeest"] )
    end

  end
end


def create_admin(provider, first_name, last_name)
  FactoryGirl.create :advocate, :admin, provider: provider, user: FactoryGirl.create(:user, first_name: first_name, last_name: last_name)
end

def create_advocate(provider, first_name, last_name)
  FactoryGirl.create :advocate, provider: provider, user: FactoryGirl.create(:user, first_name: first_name, last_name: last_name)
end
