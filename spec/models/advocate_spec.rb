# == Schema Information
#
# Table name: advocates
#
#  id              :integer          not null, primary key
#  role            :string
#  chamber_id      :integer
#  created_at      :datetime
#  updated_at      :datetime
#  supplier_number :string
#  uuid            :uuid
#

require 'rails_helper'

RSpec.describe Advocate, type: :model do
  it { should belong_to(:chamber) }
  it { should belong_to(:provider) }
  it { should have_many(:claims) }
  it { should have_many(:claims_created) }
  it { should have_many(:documents) }
  it { should have_one(:user) }

  it { should validate_presence_of(:chamber) }
  # it { should validate_presence_of(:provider) }
  it { should validate_presence_of(:user) }

  it { should accept_nested_attributes_for(:user) }

  it { should delegate_method(:email).to(:user) }
  it { should delegate_method(:first_name).to(:user) }
  it { should delegate_method(:last_name).to(:user) }
  it { should delegate_method(:name).to(:user) }

  it { should validate_inclusion_of(:role).in_array(%w( admin advocate )) }

  it { should validate_presence_of(:supplier_number) }

  context 'supplier number validation' do

    it 'should fail validation if too long' do
      a = FactoryGirl.build :advocate, supplier_number: 'ACC123'
      expect(a).not_to be_valid
      expect(a.errors[:supplier_number]).to eq( ['must be 5 alhpa-numeric characters'] )
    end

    it 'should fail validation if too short' do
      a = FactoryGirl.build :advocate, supplier_number: 'AC12'
      expect(a).not_to be_valid
      expect(a.errors[:supplier_number]).to eq( ['must be 5 alhpa-numeric characters'] )
    end

    it 'should fail validation if not alpha-numeric' do
      a = FactoryGirl.build :advocate, supplier_number: 'AC-12'
      expect(a).not_to be_valid
      expect(a.errors[:supplier_number]).to eq( ['must be 5 alhpa-numeric characters'] )
    end

    it 'should pass validation if 5 alpha-numeric' do
      a = FactoryGirl.build :advocate, supplier_number: 'AC123'
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

  describe '#name_and_number' do
    it 'should print last name, first name and supplier number' do
      a = FactoryGirl.create(:advocate, supplier_number: 'XX878', user: FactoryGirl.create(:user, last_name: 'Smith', first_name: 'John'))
      expect(a.name_and_number).to eq "Smith, John: XX878"
    end
  end

  describe '#advocates_in_chamber' do

    it 'should raise and exception if called on a advocate who isnt an admin' do
      advocate = FactoryGirl.create :advocate
      expect {
        advocate.advocates_in_chamber
      }.to raise_error RuntimeError, "Cannot call #advocates_in_chamber on advocates who are not admins"
    end

    it 'should return a collection of advocates in same chamber in alphabetic order' do
      chamber1      = FactoryGirl.create :chamber
      chamber2      = FactoryGirl.create :chamber

      admin1_ch1    = create_admin chamber1, 'Lucy', 'Zebra'
      advocate1_ch1 = create_advocate chamber1, 'Miranda', 'Bison'
      advocate3_ch1 = create_advocate chamber1, 'Geoff', 'Elephant'

      admin1_ch2    = create_admin chamber2, 'Martin', 'Tiger'
      admin2_ch2    = create_admin chamber2, 'Robert', 'Lion'
      advocate1_ch2 = create_advocate chamber2, 'Mary', 'Hippo'
      advocate2_ch2 = create_advocate chamber2, 'Anna', 'Wildebeest'
      advocate3_ch2 = create_advocate chamber2, 'George', 'Meerkat'

      advocates = admin2_ch2.advocates_in_chamber
      expect(advocates.map(&:user).map(&:last_name)).to eq ( ["Hippo", "Lion", "Meerkat", "Tiger", "Wildebeest"] )
    end

  end
end


def create_admin(chamber, first_name, last_name)
  FactoryGirl.create :advocate, :admin, chamber: chamber, user: FactoryGirl.create(:user, first_name: first_name, last_name: last_name)
end

def create_advocate(chamber, first_name, last_name)
  FactoryGirl.create :advocate, chamber: chamber, user: FactoryGirl.create(:user, first_name: first_name, last_name: last_name)
end
