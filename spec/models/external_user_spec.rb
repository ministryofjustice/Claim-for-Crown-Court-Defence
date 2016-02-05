# == Schema Information
#
# Table name: external_users
#
#  id              :integer          not null, primary key
#  created_at      :datetime
#  updated_at      :datetime
#  supplier_number :string
#  uuid            :uuid
#  vat_registered  :boolean          default(TRUE)
#  provider_id     :integer
#  roles           :string
#

require 'rails_helper'

RSpec.describe ExternalUser, type: :model do
  it_behaves_like 'user_roles', ExternalUser, ExternalUser::ROLES

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

  context 'supplier number validation' do
    context 'when no Provider present' do
      context 'for advocate' do
        before { subject.roles = ['advocate'] }

        it 'should be valid' do
          a = build :external_user, :advocate
          expect(a).to be_valid
        end
      end

      context 'for admin' do
        before { subject.roles = ['admin'] }

        it 'should be valid' do
          a = build :external_user, :admin
          expect(a).to be_valid
        end
      end
    end

    context 'when Provider present and Provider is a "firm"' do
      let!(:provider) { create(:provider, provider_type: 'firm', supplier_number: 'ZZ123') }

      before do
        subject.provider = provider
      end

      it { should_not validate_presence_of(:supplier_number) }

      context 'for advocate' do
        before { subject.roles = ['advocate'] }

        it 'should be valid without a supplier number' do
          a = build :external_user, :advocate, provider: provider, supplier_number: nil
          expect(a).to be_valid
        end
      end

      context 'for admin' do
        before { subject.roles = ['admin'] }

        it { should_not validate_presence_of(:supplier_number) }

        it 'should be valid without a supplier number' do
          a = build :external_user, :admin, provider: provider, supplier_number: nil
          expect(a).to be_valid
        end
      end
    end

    context 'when provider present and Provider is a "chamber"' do
      let(:provider) { create(:provider, provider_type: 'chamber', supplier_number: 'XX123') }

      before do
        subject.provider = provider
      end

      context 'for advocate' do
        before { subject.roles = ['advocate'] }

        it { should validate_presence_of(:supplier_number) }

        it 'should not be valid without a supplier number' do
          a = build :external_user, provider: provider, supplier_number: nil
          expect(a).not_to be_valid
        end

        it 'should fail validation if too long' do
          a = build :external_user, supplier_number: 'ACC123', provider: provider
          expect(a).not_to be_valid
          expect(a.errors[:supplier_number]).to eq( ['must be 5 alpha-numeric characters'] )
        end

        it 'should fail validation if too short' do
          a = build :external_user, supplier_number: 'AC12', provider: provider
          expect(a).not_to be_valid
          expect(a.errors[:supplier_number]).to eq( ['must be 5 alpha-numeric characters'] )
        end

        it 'should fail validation if not alpha-numeric' do
          a = build :external_user, supplier_number: 'AC-12', provider: provider
          expect(a).not_to be_valid
          expect(a.errors[:supplier_number]).to eq( ['must be 5 alpha-numeric characters'] )
        end

        it 'should pass validation if 5 alpha-numeric' do
          a = build :external_user, supplier_number: 'AC123', provider: provider
          expect(a).to be_valid
        end
      end

      context 'for admin' do
        before { subject.roles = ['admin'] }

        it { should_not validate_presence_of(:supplier_number) }

        it 'should be valid without a supplier number' do
          a = build :external_user, :admin, provider: provider, supplier_number: nil
          expect(a).to be_valid
        end
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

  describe '#name_and_number' do
    it 'should print last name, first name and supplier number' do
      a = create(:external_user, supplier_number: 'XX878', user: create(:user, last_name: 'Smith', first_name: 'John'))
      expect(a.name_and_number).to eq "Smith, John: XX878"
    end
  end
end


def create_admin(provider, first_name, last_name)
  create :external_user, :admin, provider: provider, user: create(:user, first_name: first_name, last_name: last_name)
end

def create_external_user(provider, first_name, last_name)
  create :external_user, provider: provider, user: create(:user, first_name: first_name, last_name: last_name)
end
