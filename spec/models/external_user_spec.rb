# == Schema Information
#
# Table name: external_users
#
#  id              :integer          not null, primary key
#  roles           :string
#  provider_id     :integer
#  created_at      :datetime
#  updated_at      :datetime
#  supplier_number :string
#  uuid            :uuid
#

require 'rails_helper'

RSpec.describe ExternalUser, type: :model do
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

  context 'roles' do
    it 'is not valid when no roles present' do
      external_user = build(:external_user, roles: [])
      expect(external_user).to_not be_valid
      expect(external_user.errors[:roles]).to include('at least one role must be present')
    end

    it 'is not valid for roles not in the ROLES array' do
      external_user = build(:external_user, roles: ['foobar', 'admin', 'advocate'])
      expect(external_user).to_not be_valid
      expect(external_user.errors[:roles]).to include('must be one or more of: admin, advocate')
    end

    it 'is valid for roles in the ROLES array' do
      external_user = build(:external_user, roles: ['advocate', 'admin'])
      expect(external_user).to be_valid
    end
  end

  context 'supplier number validation' do
    context 'when no Provider present' do
      it 'should be valid' do
        a = FactoryGirl.build :external_user
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
        a = FactoryGirl.build :external_user, provider: provider, supplier_number: nil
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
        a = FactoryGirl.build :external_user, provider: provider, supplier_number: nil
        expect(a).not_to be_valid
      end

      it 'should fail validation if too long' do
        a = FactoryGirl.build :external_user, supplier_number: 'ACC123', provider: provider
        expect(a).not_to be_valid
        expect(a.errors[:supplier_number]).to eq( ['must be 5 alpha-numeric characters'] )
      end

      it 'should fail validation if too short' do
        a = FactoryGirl.build :external_user, supplier_number: 'AC12', provider: provider
        expect(a).not_to be_valid
        expect(a.errors[:supplier_number]).to eq( ['must be 5 alpha-numeric characters'] )
      end

      it 'should fail validation if not alpha-numeric' do
        a = FactoryGirl.build :external_user, supplier_number: 'AC-12', provider: provider
        expect(a).not_to be_valid
        expect(a.errors[:supplier_number]).to eq( ['must be 5 alpha-numeric characters'] )
      end

      it 'should pass validation if 5 alpha-numeric' do
        a = FactoryGirl.build :external_user, supplier_number: 'AC123', provider: provider
        expect(a).to be_valid
      end
    end
  end

  describe '#supplier_number' do
    subject { create(:external_user, provider: provider, supplier_number: 'XY123') }

    context 'when external_user in chamber' do
      let(:provider) { create(:provider, :chamber, supplier_number: 'AB123') }

      it "returns the external_user's supplier number" do
        expect(subject.supplier_number).to eq('XY123')
      end
    end

    context 'when external_user in firm' do
      let(:provider) { create(:provider, :firm, supplier_number: 'AB123') }

      it "returns the provider's supplier number" do
        expect(subject.supplier_number).to eq('AB123')
      end
    end
  end

  describe '#vat_registered?' do
    subject { create(:external_user, provider: provider, vat_registered: false) }

    context 'when external_user in chamber' do
      let(:provider) { create(:provider, :chamber, vat_registered: true) }

      it "returns the external_user's VAT registration status" do
        expect(subject.vat_registered?).to eq(false)
      end
    end

    context 'when external_user in firm' do
      let(:provider) { create(:provider, :firm, vat_registered: true) }

      it "returns the provider's VAT registration status" do
        expect(subject.vat_registered?).to eq(true)
      end
    end
  end

  describe '#name' do
    subject { create(:external_user) }

    it 'returns the first and last names' do
      expect(subject.name).to eq("#{subject.first_name} #{subject.last_name}")
    end
  end

  describe 'ROLES' do
    it 'should have "admin" and "advocate"' do
      expect(ExternalUser::ROLES).to match_array(%w( admin advocate ))
    end
  end

  describe '.admins' do
    before do
      create(:external_user, :admin)
      create(:external_user, :advocate)
    end

    it 'only returns external_users with role "admin"' do
      expect(ExternalUser.admins.count).to eq(1)
    end

    it 'returns external_users with role "admin" and "advocate"' do
      e = ExternalUser.first
      e.roles = ['admin', 'advocate']
      e.save!
      expect(ExternalUser.admins.count).to eq(1)
    end
  end

  describe '.advocates' do
    before do
      create(:external_user, :admin)
      create(:external_user, :admin)
      create(:external_user)
    end

    it 'only returns external_users with role "advocate"' do
      expect(ExternalUser.advocates.count).to eq(1)
    end

    it 'returns external_users with role "admin" and "advocate"' do
      e = ExternalUser.last
      e.roles = ['admin', 'advocate']
      e.save!
      expect(ExternalUser.advocates.count).to eq(1)
    end
  end

  describe 'roles' do
    let(:admin) { create(:external_user, :admin) }
    let(:advocate) { create(:external_user, :advocate) }

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
      a = FactoryGirl.create(:external_user, supplier_number: 'XX878', user: FactoryGirl.create(:user, last_name: 'Smith', first_name: 'John'))
      expect(a.name_and_number).to eq "Smith, John: XX878"
    end
  end

  describe '#external_users_in_provider' do

    it 'should raise and exception if called on a advocate who isnt an admin' do
      external_user = FactoryGirl.create :external_user
      expect {
        external_user.external_users_in_provider
      }.to raise_error RuntimeError, "Cannot call #external_users_in_provider on external users who are not admins"
    end

    it 'should return a collection of external users in same provider in alphabetic order' do
      provider1      = FactoryGirl.create :provider
      provider2      = FactoryGirl.create :provider

      admin1_ch1    = create_admin provider1, 'Lucy', 'Zebra'
      external_user1_ch1 = create_external_user provider1, 'Miranda', 'Bison'
      external_user3_ch1 = create_external_user provider1, 'Geoff', 'Elephant'

      admin1_ch2    = create_admin provider2, 'Martin', 'Tiger'
      admin2_ch2    = create_admin provider2, 'Robert', 'Lion'
      external_user1_ch2 = create_external_user provider2, 'Mary', 'Hippo'
      external_user2_ch2 = create_external_user provider2, 'Anna', 'Wildebeest'
      external_user3_ch2 = create_external_user provider2, 'George', 'Meerkat'

      external_users = admin2_ch2.external_users_in_provider
      expect(external_users.map(&:user).map(&:last_name)).to eq ( ["Hippo", "Lion", "Meerkat", "Tiger", "Wildebeest"] )
    end

  end
end


def create_admin(provider, first_name, last_name)
  FactoryGirl.create :external_user, :admin, provider: provider, user: FactoryGirl.create(:user, first_name: first_name, last_name: last_name)
end

def create_external_user(provider, first_name, last_name)
  FactoryGirl.create :external_user, provider: provider, user: FactoryGirl.create(:user, first_name: first_name, last_name: last_name)
end
