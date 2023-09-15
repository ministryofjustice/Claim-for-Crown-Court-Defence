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

RSpec.describe ExternalUser do
  it_behaves_like 'roles', described_class, described_class::ROLES

  it { is_expected.to belong_to(:provider) }
  it { is_expected.to have_many(:claims) }
  it { is_expected.to have_many(:claims_created) }
  it { is_expected.to have_many(:documents) }
  it { is_expected.to have_one(:user) }

  it { is_expected.to validate_presence_of(:provider) }
  it { is_expected.to validate_presence_of(:user) }

  it { is_expected.to accept_nested_attributes_for(:user) }

  it { is_expected.to delegate_method(:email).to(:user) }
  it { is_expected.to delegate_method(:first_name).to(:user) }
  it { is_expected.to delegate_method(:last_name).to(:user) }
  it { is_expected.to delegate_method(:name).to(:user) }
  it { is_expected.to delegate_method(:agfs?).to(:provider) }
  it { is_expected.to delegate_method(:lgfs?).to(:provider) }

  it_behaves_like 'a disablable delegator', :user

  context 'supplier number validation' do
    context 'when no Provider present' do
      context 'for advocate' do
        before { subject.roles = ['advocate'] }

        it 'is valid' do
          a = build(:external_user, :advocate)
          expect(a).to be_valid
        end
      end

      context 'for admin' do
        before { subject.roles = ['admin'] }

        it 'is valid' do
          a = build(:external_user, :admin)
          expect(a).to be_valid
        end
      end
    end

    context 'when Provider present and Provider is a "firm"' do
      let!(:provider) { create(:provider, :agfs_lgfs, firm_agfs_supplier_number: 'ZZ123') }

      before do
        subject.provider = provider
      end

      it { is_expected.not_to validate_presence_of(:supplier_number) }

      context 'for advocate' do
        before { subject.roles = ['advocate'] }

        it 'is valid without a supplier number' do
          a = build(:external_user, :advocate, provider:, supplier_number: nil)
          expect(a).to be_valid
        end
      end

      context 'for admin' do
        before { subject.roles = ['admin'] }

        it { is_expected.not_to validate_presence_of(:supplier_number) }

        it 'is valid without a supplier number' do
          a = build(:external_user, :admin, provider:, supplier_number: nil)
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

        let(:format_error) { ['Enter a valid supplier number'] }

        it { is_expected.to validate_presence_of(:supplier_number) }

        it 'is not valid without a supplier number' do
          a = build(:external_user, provider:, supplier_number: nil)
          expect(a).not_to be_valid
        end

        it 'fails validation if too long' do
          a = build(:external_user, supplier_number: 'ACC123', provider:)
          expect(a).not_to be_valid
          expect(a.errors[:supplier_number]).to eq(format_error)
        end

        it 'fails validation if too short' do
          a = build(:external_user, supplier_number: 'AC12', provider:)
          expect(a).not_to be_valid
          expect(a.errors[:supplier_number]).to eq(format_error)
        end

        it 'fails validation if not alpha-numeric' do
          a = build(:external_user, supplier_number: 'AC-12', provider:)
          expect(a).not_to be_valid
          expect(a.errors[:supplier_number]).to eq(format_error)
        end

        it 'passes validation if 5 alpha-numeric' do
          a = build(:external_user, supplier_number: 'AC123', provider:)
          expect(a).to be_valid
        end
      end

      context 'for admin' do
        before { subject.roles = ['admin'] }

        it { is_expected.not_to validate_presence_of(:supplier_number) }

        it 'is valid without a supplier number' do
          a = build(:external_user, :admin, provider:, supplier_number: nil)
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
    it 'has "admin" and "advocate" and "litigator"' do
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

  # Methods from Roles module
  describe '#is?' do
    subject { user.is?(role) }

    context 'with an advocate user' do
      let(:user) { create(:external_user, :advocate) }

      context 'when testing for advocate' do
        let(:role) { :advocate }

        it { is_expected.to be_truthy }
      end

      context 'when testing for admin' do
        let(:role) { :admin }

        it { is_expected.to be_falsey }
      end
    end

    context 'with an admin user' do
      let(:user) { create(:external_user, :admin) }

      context 'when testing for advocate' do
        let(:role) { :advocate }

        it { is_expected.to be_falsey }
      end

      context 'when testing for admin' do
        let(:role) { :admin }

        it { is_expected.to be_truthy }
      end
    end
  end

  describe '#advocate?' do
    subject { user.advocate? }

    context 'with an advocate user' do
      let(:user) { create(:external_user, :advocate) }

      it { is_expected.to be_truthy }
    end

    context 'with an admin user' do
      let(:user) { create(:external_user, :admin) }

      it { is_expected.to be_falsey }
    end
  end

  describe '#admin?' do
    subject { user.admin? }

    context 'with an advocate user' do
      let(:user) { create(:external_user, :advocate) }

      it { is_expected.to be_falsey }
    end

    context 'with an admin user' do
      let(:user) { create(:external_user, :admin) }

      it { is_expected.to be_truthy }
    end
  end
  # End of methods from Roles module

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

    let(:user) { create(:external_user, :advocate, provider:) }

    context "when the user's provider handles both AGFS and LGFS claims" do
      let(:provider) { build(:provider, :agfs_lgfs) }

      it { is_expected.to match_array %w[admin advocate litigator] }
    end

    context "when the user's provider handles only AGFS claims" do
      let(:provider) { build(:provider, :agfs) }

      it { is_expected.to match_array %w[admin advocate] }
    end

    context "when the user's provider handles only LGFS claims" do
      let(:provider) { build(:provider, :lgfs) }

      it { is_expected.to match_array %w[admin litigator] }
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

  context 'with live and softly deleted users' do
    let!(:live_users) { create_list(:external_user, 2) }
    let!(:dead_users) { create_list(:external_user, 2, :softly_deleted) }

    context 'with the active scope' do
      subject(:records) { described_class.active }

      it { is_expected.to match_array(live_users) }
      it { expect { records.find(dead_users.first.id) }.to raise_error ActiveRecord::RecordNotFound }
      it { expect(records.where(id: dead_users.map(&:id))).to be_empty }
    end

    context 'with the softly deleted scope' do
      subject(:records) { described_class.softly_deleted }

      it { is_expected.to match_array(dead_users) }
      it { expect { records.find(live_users.first.id) }.to raise_error ActiveRecord::RecordNotFound }
      it { expect(records.where(id: live_users.map(&:id))).to be_empty }
    end

    describe 'with the default scope' do
      subject(:records) { described_class.all }

      it { is_expected.to match_array((live_users + dead_users)) }
      it { expect(records.find(dead_users.first.id)).to eq dead_users.first }
      it { expect(records.where(id: dead_users.map(&:id))).to match_array(dead_users) }
    end
  end

  describe '#soft_delete' do
    subject(:soft_delete) { external_user.soft_delete }

    let(:external_user) { create(:external_user) }

    it { expect { soft_delete }.to change(external_user, :deleted_at).from(nil) }
    it { expect { soft_delete }.to change(external_user.user, :deleted_at).from(nil) }
  end

  describe '#active?' do
    it 'returns false for deleted records' do
      eu = build(:external_user, :softly_deleted)
      expect(eu.active?).to be false
    end

    it 'returns true for active records' do
      eu = build(:external_user)
      expect(eu.active?).to be true
    end
  end

  describe '#supplier_number' do
    subject { external_user.supplier_number }

    context 'with a supplier number' do
      let(:external_user) { create(:external_user, :advocate, supplier_number: 'ZZ114') }

      it { is_expected.to eq 'ZZ114' }
    end

    context 'when the supplier number set in the provider' do
      let(:provider) { create(:provider, :agfs_lgfs, firm_agfs_supplier_number: '999XX') }
      let(:external_user) { create(:external_user, :advocate, supplier_number: nil, provider:) }

      it { is_expected.to eq '999XX' }
    end
  end

  describe '#send_email_notification_of_message?' do
    subject { external_user.send_email_notification_of_message? }

    let(:external_user) { build(:external_user) }

    it { is_expected.to be_falsey }

    context 'when email_notification_of_message is set to true by name' do
      before { external_user.email_notification_of_message = 'true' }

      it { is_expected.to be_truthy }
    end

    context 'when email_notification_of_message is set to false by name' do
      before { external_user.email_notification_of_message = 'false' }

      it { is_expected.to be_falsey }
    end

    context 'when email_notification_of_message is set to true in settings' do
      before { external_user.save_settings!(email_notification_of_message: true) }

      it { is_expected.to be_truthy }
    end

    context 'when email_notification_of_message is set to false in settings' do
      before { external_user.save_settings!(email_notification_of_message: false) }

      it { is_expected.to be_falsey }
    end
  end
end
