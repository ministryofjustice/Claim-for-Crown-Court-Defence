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
#  deleted_at      :datetime
#

require 'rails_helper'
require 'support/shared_examples_for_claim_types'

RSpec.describe ExternalUser, type: :model do
  it_behaves_like 'roles', ExternalUser, ExternalUser::ROLES

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
  it { should delegate_method(:agfs?).to(:provider) }
  it { should delegate_method(:lgfs?).to(:provider) }

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
      let!(:provider) { create(:provider, :agfs_lgfs, firm_agfs_supplier_number: 'ZZ123') }

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
      let(:provider) { create(:provider, provider_type: 'chamber', firm_agfs_supplier_number: '') }

      before do
        subject.provider = provider
      end

      context 'for advocate' do
        before { subject.roles = ['advocate'] }

        let(:format_error) { ['must be 5 alpha-numeric uppercase characters'] }

        it { should validate_presence_of(:supplier_number) }

        it 'should not be valid without a supplier number' do
          a = build :external_user, provider: provider, supplier_number: nil
          expect(a).not_to be_valid
        end

        it 'should fail validation if too long' do
          a = build :external_user, supplier_number: 'ACC123', provider: provider
          expect(a).not_to be_valid
          expect(a.errors[:supplier_number]).to eq(format_error)
        end

        it 'should fail validation if too short' do
          a = build :external_user, supplier_number: 'AC12', provider: provider
          expect(a).not_to be_valid
          expect(a.errors[:supplier_number]).to eq(format_error)
        end

        it 'should fail validation if not alpha-numeric' do
          a = build :external_user, supplier_number: 'AC-12', provider: provider
          expect(a).not_to be_valid
          expect(a.errors[:supplier_number]).to eq(format_error)
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

  describe '#name' do
    subject { create(:external_user) }

    it 'returns the first and last names' do
      expect(subject.name).to eq("#{subject.first_name} #{subject.last_name}")
    end
  end

  describe 'ROLES' do
    it 'should have "admin" and "advocate" and "litigator"' do
      expect(ExternalUser::ROLES).to match_array(%w(admin advocate litigator))
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
      e.supplier_number = 'ZA111'
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

  describe '#available_claim_types' do
    subject { user.available_claim_types.map(&:to_s) }

    include_context 'claim-types object helpers'

    context 'for users with only an advocate role' do
      let(:user) { build(:external_user, :advocate) }
      it { is_expected.to match_array(agfs_claim_object_types) }
    end

    context 'for users with only a litigator role' do
      let(:user) { build(:external_user, :litigator) }
      it { is_expected.to match_array(lgfs_claim_object_types) }
    end

    context 'for users with an admin role' do
      let(:user) { build(:external_user, :admin, provider: build(:provider, :agfs)) }

      # TODO: i believe this is flawed as an admin should delegate available claim types to the provider)
      # e.g. an admin in an agfs only provider can only create advocate claims
      it { is_expected.to match_array(all_claim_object_types) }
    end

    context 'for users with both an advocate and litigator role in provider with both agfs and lgfs role' do
      let(:user) { build(:external_user, :advocate_litigator) }
      it { is_expected.to match_array(all_claim_object_types) }
    end
  end

  describe '#available_roles' do
    subject { user.available_roles }
    let(:user) { create(:external_user, :advocate, provider: provider) }

    # Note: there is provider cannot be blank validation - pointless test?
    context 'when the user does not belong to a provider' do
      let(:provider) { build(:provider) }
      before { user.provider = nil }
      it 'returns admin' do
        is_expected.to match_array %w[admin]
      end
    end

    context 'when the user belongs to a provider that' do
      context 'handles both AGFS and LGFS claims' do
        let(:provider) { build(:provider, :agfs_lgfs) }
        it { is_expected.to match_array %w[admin advocate litigator] }
      end

      context 'handles only AGFS claims' do
        let(:provider) { build(:provider, :agfs) }
        it { is_expected.to match_array %w[admin advocate] }
      end

      context 'handles only LGFS claims' do
        let(:provider) { build(:provider, :lgfs) }
        it { is_expected.to match_array %w[admin litigator] }
      end
    end

    context 'when an invalid role supplied' do
      let(:provider) { build(:provider) }
      before { user.provider.roles = %w[invalid_role] }
      it 'raises an error' do
        expect { user.available_roles }.to raise_error(RuntimeError)
      end
    end
  end

  describe '#name_and_number' do
    it 'returns last name, first name and supplier number' do
      a = create(:external_user, supplier_number: 'XX878', user: create(:user, last_name: 'Smith', first_name: 'John'))
      expect(a.name_and_number).to eq 'Smith, John (XX878)'
    end
  end

  context 'soft deletions' do
    before(:all) do
      @live_user_1 = create :external_user
      @live_user_2 = create :external_user
      @dead_user_1 = create :external_user, :softly_deleted
      @dead_user_2 = create :external_user, :softly_deleted
    end

    after(:all) { clean_database }

    describe 'active scope' do
      it 'should only return undeleted records' do
        expect(ExternalUser.active.order(:id)).to eq([@live_user_1, @live_user_2])
      end

      it 'should return ActiveRecord::RecordNotFound if find by id relates to a deleted record' do
        expect {
          ExternalUser.active.find(@dead_user_1.id)
        }.to raise_error ActiveRecord::RecordNotFound, %Q{Couldn't find ExternalUser with 'id'=#{@dead_user_1.id} [WHERE "external_users"."deleted_at" IS NULL]}
      end

      it 'returns an empty array if the selection criteria only reference deleted records' do
        expect(ExternalUser.active.where(id: [@dead_user_1.id, @dead_user_2.id])).to be_empty
      end
    end

    describe 'deleted scope' do
      it 'should return only deleted records' do
        expect(ExternalUser.softly_deleted.order(:id)).to eq([@dead_user_1, @dead_user_2])
      end

      it 'should return ActiveRecord::RecordNotFound if find by id relates to an undeleted record' do
        expect(ExternalUser.find(@live_user_1.id)).to eq(@live_user_1)
        expect {
          ExternalUser.softly_deleted.find(@live_user_1.id)
        }.to raise_error ActiveRecord::RecordNotFound, /Couldn't find ExternalUser with 'id'=#{@live_user_1.id}/
      end

      it 'returns an empty array if the selection criteria only reference live records' do
        expect(User.softly_deleted.where(id: [@live_user_1.id, @live_user_2.id])).to be_empty
      end
    end

    describe 'default scope' do
      it 'should return deleted and undeleted records' do
        expect(ExternalUser.order(:id)).to eq([@live_user_1, @live_user_2, @dead_user_1, @dead_user_2])
      end

      it 'should return the record if find by id relates to a deleted record' do
        expect(ExternalUser.find(@dead_user_1.id)).to eq @dead_user_1
      end

      it 'returns the deleted records if the selection criteria reference only deleted records' do
        expect(ExternalUser.where(id: [@dead_user_1.id, @dead_user_2.id]).order(:id)).to eq([@dead_user_1, @dead_user_2])
      end
    end
  end

  describe 'soft_delete' do
    it 'should set deleted at on the caseworker and user records' do
      eu = create :external_user
      user = eu.user
      eu.soft_delete
      expect(eu.reload.deleted_at).not_to be_nil
      expect(user.reload.deleted_at).not_to be_nil
    end
  end

  describe '#active?' do
    it 'returns false for deleted records' do
      eu = build :external_user, :softly_deleted
      expect(eu.active?).to be false
    end

    it 'returns true for active records' do
      eu = build :external_user
      expect(eu.active?).to be true
    end
  end

  describe 'supplier_number' do
    context 'supplier number present' do
      let(:external_user) { create :external_user, :advocate, supplier_number: 'ZZ114' }

      it 'returns the supplier number from the external user record' do
        expect(external_user.supplier_number).to eq 'ZZ114'
      end
    end

    context 'supplier number not present but provider is a firm' do
      let(:provider) { create :provider, :agfs_lgfs, firm_agfs_supplier_number: '999XX' }
      let(:external_user) { create :external_user, :advocate, supplier_number: nil, provider: provider }

      it 'returns the firm_agfs_supplier_number from the provider' do
        expect(external_user.supplier_number).to eq '999XX'
      end
    end
  end

  context 'email notification of messages preferences' do
    context 'settings on user record are nil' do
      let(:eu) { build :external_user }

      it 'has an underlying user setting of nil' do
        expect(eu.user.settings).to eq Hash.new
      end

      it 'returns false' do
        expect(eu.send_email_notification_of_message?).to be false
      end

      it 'sets the setting to true' do
        eu.email_notification_of_message = 'true'
        expect(eu.send_email_notification_of_message?).to be true
      end

      it 'sets the setting to false' do
        eu.email_notification_of_message = 'false'
        expect(eu.send_email_notification_of_message?).to be false
      end
    end

    context 'no setttings for email notifications present' do
      let(:eu)  { build :external_user, :with_settings }

      it 'returns false' do
        expect(eu.settings).to eq({ 'setting1' => 'test1', 'setting2' => 'test2' })
        expect(eu.send_email_notification_of_message?).to be false
      end
      it 'sets the setting to true' do
        eu.email_notification_of_message = 'true'
        expect(eu.send_email_notification_of_message?).to be true
      end

      it 'sets the setting to false' do
        eu.email_notification_of_message = 'false'
        expect(eu.send_email_notification_of_message?).to be false
      end
    end

    context 'settings for email notification are true' do
      let(:eu) { build :external_user, :with_email_notification_of_messages }

      it 'returns true' do
        expect(eu.send_email_notification_of_message?).to be true
      end

      it 'sets the setting to false' do
        eu.email_notification_of_message = 'false'
        expect(eu.send_email_notification_of_message?).to be false
      end
    end

    context 'settings for email notification are false' do
      let(:eu) { build :external_user, :without_email_notification_of_messages }

      it 'returns false' do
        expect(eu.send_email_notification_of_message?).to be false
      end

      it 'sets the setting to true' do
        eu.email_notification_of_message = 'true'
        expect(eu.send_email_notification_of_message?).to be true
      end
    end
  end
end

def create_admin(provider, first_name, last_name)
  create :external_user, :admin, provider: provider, user: create(:user, first_name: first_name, last_name: last_name)
end

def create_external_user(provider, first_name, last_name)
  create :external_user, provider: provider, user: create(:user, first_name: first_name, last_name: last_name)
end
