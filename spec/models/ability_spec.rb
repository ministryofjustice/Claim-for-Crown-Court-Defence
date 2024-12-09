require 'rails_helper'
require 'cancan/matchers'
require 'support/shared_examples_for_claim_types'

RSpec.shared_examples 'user cannot' do |user, actions|
  actions.each do |action|
    it { should_not be_able_to(action, user) }
  end
end

ALL_EXTERNAL_USER_ACTIONS = %i[show show_message_controls edit update summary unarchive confirmation
                               clone_rejected destroy].freeze

RSpec.describe Ability do
  subject { Ability.new(user) }

  let(:user) { nil }
  let(:another_user) { create(:external_user).user }

  include_context 'claim-types object helpers'

  context 'when not a signed in user' do
    it { should_not be_able_to(:create, Message.new) }
    it { should_not be_able_to(:download_attachment, Message.new) }
    it { should_not be_able_to(:index, UserMessageStatus) }
    it { should_not be_able_to(:update, UserMessageStatus.new) }
    it { should_not be_able_to(:create, Document.new) }
    it { should_not be_able_to(:update_settings, User.new) }

    context 'with user management' do
      it { is_expected.not_to be_able_to(:index, User) }
    end

    it { is_expected.not_to be_able_to(:index, CourtData) }
  end

  context 'when a signed in user' do
    let(:user) { create(:external_user).user }

    it { should be_able_to(:create, Message.new) }
    it { should be_able_to(:download_attachment, Message.new) }
    it { should be_able_to(:index, UserMessageStatus) }
    it { should be_able_to(:update, UserMessageStatus.new) }

    it { should be_able_to(:update_settings, user) }
    it { should_not be_able_to(:update_settings, another_user) }

    context 'with user management' do
      it { is_expected.not_to be_able_to(:index, User) }
    end
  end

  context 'external_user advocate' do
    let(:external_user) { create(:external_user, :advocate) }
    let(:provider) { external_user.provider }
    let(:user) { external_user.user }

    [:create].each do |action|
      it { should be_able_to(action, ClaimIntention) }
    end

    %i[index outstanding authorised archived new create].each do |action|
      agfs_claim_type_objects.each do |model|
        it { should be_able_to(action, model) }
      end

      lgfs_claim_type_objects.each do |model|
        it { should_not be_able_to(action, model) }
      end
    end

    context 'can manage their own claims' do
      ALL_EXTERNAL_USER_ACTIONS.each do |action|
        agfs_claim_type_objects.each do |model|
          it { should be_able_to(action, model.new(external_user:)) }
        end
      end
    end

    context 'cannot manage claims by another external_user in the same provider' do
      let(:other_external_user) { create(:external_user, :advocate, provider:) }

      ALL_EXTERNAL_USER_ACTIONS.each do |action|
        agfs_claim_type_objects.each do |model|
          it { should_not be_able_to(action, model.new(external_user: other_external_user)) }
        end
      end
    end

    context 'can index, create and upload documents' do
      %i[index create upload].each do |action|
        it { should be_able_to(action, Document.new(external_user:)) }
      end
    end

    context 'can view/download/destroy their own documents' do
      %i[show download destroy].each do |action|
        it { should be_able_to(action, Document.new(external_user:)) }
      end
    end

    context 'cannot view/download/destroy another external_user\'s documents' do
      let(:other_external_user) { create(:external_user) }

      %i[show download destroy].each do |action|
        it { should_not be_able_to(action, Document.new(external_user: other_external_user)) }
      end
    end

    context 'cannot manage external_user\'s' do
      %i[show edit update destroy change_password update_password].each do |action|
        it { should_not be_able_to(action, ExternalUser.new(provider: external_user.provider)) }
      end
    end

    context 'can view profile and change own password' do
      %i[show change_password update_password].each do |action|
        it { should be_able_to(action, external_user) }
      end
    end

    context 'cannot manage their provider' do
      %i[show edit update regenerate_api_key].each do |action|
        it { should_not be_able_to(action, provider) }
      end
    end

    context 'cannot manage other providers' do
      let(:other_provider) { create(:provider) }

      %i[show edit update regenerate_api_key].each do |action|
        it { should_not be_able_to(action, other_provider) }
      end
    end

    context 'with user management' do
      it { is_expected.not_to be_able_to(:index, User) }
    end

    it { is_expected.not_to be_able_to(:index, CourtData) }
  end

  context 'external_user admin' do
    let(:provider) { create(:provider) }
    let(:external_user) { create(:external_user, :admin, provider:) }
    let(:user) { external_user.user }

    [:create].each do |action|
      it { should be_able_to(action, ClaimIntention) }
    end

    %i[index outstanding authorised archived new create].each do |action|
      all_claim_type_objects.each do |model|
        it { should be_able_to(action, model) }
      end
    end

    context 'can manage their own claims' do
      ALL_EXTERNAL_USER_ACTIONS.each do |action|
        all_claim_type_objects.each do |model|
          it { should be_able_to(action, model.new(external_user:, creator: external_user)) }
        end
      end
    end

    context 'can manage claims by another external_user in the same provider' do
      let(:other_external_user) { create(:external_user, provider:) }

      ALL_EXTERNAL_USER_ACTIONS.each do |action|
        all_claim_type_objects.each do |model|
          it { should be_able_to(action, model.new(external_user: other_external_user, creator: external_user)) }
        end
      end
    end

    context 'cannot manage claims by another external_user with a different provider' do
      let(:other_external_user) { create(:external_user, :advocate) }

      ALL_EXTERNAL_USER_ACTIONS.each do |action|
        all_claim_type_objects.each do |model|
          it {
            should_not be_able_to(action, model.new(external_user: other_external_user, creator: other_external_user))
          }
        end
      end
    end

    context 'can manage their provider' do
      %i[show edit update regenerate_api_key].each do |action|
        it { should be_able_to(action, provider) }
      end
    end

    context 'cannot manage other providers' do
      let(:other_provider) { create(:provider) }

      %i[show edit update regenerate_api_key].each do |action|
        it { should_not be_able_to(action, other_provider) }
      end
    end

    context 'can index, create and upload documents' do
      %i[index create upload].each do |action|
        it { should be_able_to(action, Document.new(external_user:)) }
      end
    end

    context 'can view/download/destroy their own documents' do
      %i[show download destroy].each do |action|
        it { should be_able_to(action, Document.new(external_user:)) }
      end
    end

    context 'can view/download/destroy documents by an external_user in the same provider' do
      let(:other_external_user) { create(:external_user, provider:) }

      %i[show download destroy].each do |action|
        it { should be_able_to(action, Document.new(external_user: other_external_user)) }
      end
    end

    context 'cannot view/download/destroy another external_user\'s documents from a different provider' do
      let(:other_external_user) { create(:external_user) }

      %i[show download destroy].each do |action|
        it { should_not be_able_to(action, Document.new(external_user: other_external_user)) }
      end
    end

    context 'can manage external_users in their provider' do
      %i[show edit update destroy change_password update_password].each do |action|
        it { should be_able_to(action, ExternalUser.new(provider:)) }
      end
    end

    context 'cannot manage external_users in a different provider' do
      let(:other_provider) { create(:provider) }

      %i[show edit update destroy change_password update_password].each do |action|
        it { should_not be_able_to(action, ExternalUser.new(provider: other_provider)) }
      end
    end

    context 'with user management' do
      it { is_expected.not_to be_able_to(:index, User) }
    end

    it { is_expected.not_to be_able_to(:index, CourtData) }
  end

  context 'external_user litigator' do
    let(:external_user) { create(:external_user, :litigator) }
    let(:provider)      { external_user.provider }
    let(:user)          { external_user.user }

    [:create].each do |action|
      it { should be_able_to(action, ClaimIntention) }
    end

    %i[index outstanding authorised archived new create].each do |action|
      lgfs_claim_type_objects.each do |model|
        it { should be_able_to(action, model) }
      end

      agfs_claim_type_objects.each do |model|
        it { should_not be_able_to(action, model) }
      end
    end

    context 'can manage their own claims' do
      ALL_EXTERNAL_USER_ACTIONS.each do |action|
        lgfs_claim_type_objects.each do |model|
          it { should be_able_to(action, model.new(external_user:)) }
        end
      end
    end

    context 'cannot manage claims by another external_user with a different provider' do
      let(:other_external_user) { create(:external_user, :litigator) }

      ALL_EXTERNAL_USER_ACTIONS.each do |action|
        lgfs_claim_type_objects.each do |model|
          it { should_not be_able_to(action, model.new(external_user: other_external_user)) }
        end
      end
    end

    context 'can view/download/destroy their own documents' do
      %i[show download destroy].each do |action|
        it { should be_able_to(action, Document.new(external_user:)) }
      end
    end

    context 'can index and create documents' do
      %i[index create].each do |action|
        it { should be_able_to(action, Document.new(external_user:)) }
      end
    end

    context 'cannot view/download/destroy another external_user\'s documents' do
      let(:other_external_user) { create(:external_user) }

      %i[show download destroy].each do |action|
        it { should_not be_able_to(action, Document.new(external_user: other_external_user)) }
      end
    end

    context 'cannot manage external_users in their provider' do
      %i[show edit update destroy change_password update_password].each do |action|
        it { should_not be_able_to(action, ExternalUser.new(provider:)) }
      end
    end

    context 'with user management' do
      it { is_expected.not_to be_able_to(:index, User) }
    end

    it { is_expected.not_to be_able_to(:index, CourtData) }
  end

  context 'external_user litigator admin' do
    let(:external_user) { create(:external_user, :litigator_and_admin) }
    let(:provider)      { external_user.provider }
    let(:user)          { external_user.user }

    [:create].each do |action|
      it { should be_able_to(action, ClaimIntention) }
    end

    %i[index outstanding authorised archived new create].each do |action|
      [Claim::LitigatorClaim, Claim::InterimClaim, Claim::TransferClaim].each do |model|
        it { should be_able_to(action, model) }
      end
    end

    context 'can manage their own claims' do
      ALL_EXTERNAL_USER_ACTIONS.each do |action|
        [Claim::LitigatorClaim, Claim::InterimClaim, Claim::TransferClaim].each do |model|
          it { should be_able_to(action, model.new(external_user:, creator: external_user)) }
        end
      end
    end

    context 'can manage claims by another external_user in the same provider' do
      let(:other_external_user) { create(:external_user, provider:) }

      ALL_EXTERNAL_USER_ACTIONS.each do |action|
        lgfs_claim_type_objects.each do |model|
          it { should be_able_to(action, model.new(external_user: other_external_user, creator: external_user)) }
        end
      end
    end

    context 'cannot manage claims by another external_user in a different provider' do
      let(:other_external_user) { create(:external_user, :litigator) }

      ALL_EXTERNAL_USER_ACTIONS.each do |action|
        lgfs_claim_type_objects.each do |model|
          it {
            should_not be_able_to(action, model.new(external_user: other_external_user, creator: other_external_user))
          }
        end
      end
    end

    context 'can view/download/destroy their own documents' do
      %i[show download destroy].each do |action|
        it { should be_able_to(action, Document.new(external_user:)) }
      end
    end

    context 'can index and create documents' do
      %i[index create].each do |action|
        it { should be_able_to(action, Document.new(external_user:)) }
      end
    end

    context 'cannot view/download/destroy another external_user\'s documents in a different provider' do
      let(:other_external_user) { create(:external_user) }

      %i[show download destroy].each do |action|
        it { should_not be_able_to(action, Document.new(external_user: other_external_user)) }
      end
    end

    context 'can view/download/destroy documents by an external_user in the same provider' do
      let(:other_external_user) { create(:external_user, provider:) }

      %i[show download destroy].each do |action|
        it { should be_able_to(action, Document.new(external_user: other_external_user)) }
      end
    end

    context 'can manage external_users in their provider' do
      %i[show edit update destroy change_password update_password].each do |action|
        it { should be_able_to(action, ExternalUser.new(provider:)) }
      end
    end

    context 'with user management' do
      it { is_expected.not_to be_able_to(:index, User) }
    end

    it { is_expected.not_to be_able_to(:index, CourtData) }
  end

  context 'case worker' do
    let(:case_worker) { create(:case_worker) }
    let(:user) { case_worker.user }

    it { should be_able_to(:update_settings, user) }
    it { should_not be_able_to(:update_settings, another_user) }

    %i[index archived show show_message_controls].each do |action|
      it { should be_able_to(action, Claim::AdvocateClaim.new) }
    end

    context 'can update claim when assigned to claim' do
      let(:claim) { create(:advocate_claim) }

      before { case_worker.claims << claim }

      it { should be_able_to(:update, claim) }
    end

    context 'cannot update claim when not assigned to claim' do
      all_claim_type_objects.each do |model|
        it { should_not be_able_to(:update, model.new) }
      end
    end

    context 'can view/download documents' do
      %i[show download].each do |action|
        it { should be_able_to(action, Document.new) }
      end
    end

    context 'can view their own profile' do
      it { should be_able_to(:show, case_worker) }
    end

    context 'cannot view other profiles' do
      it { should_not be_able_to(:show, CaseWorker.new) }
    end

    context 'cannot manage case workers' do
      %i[index show new create edit change_password update_password update destroy].each do |action|
        it { should_not be_able_to(action, CaseWorker.new) }
      end
    end

    context 'can view their own profile and change password' do
      %i[show change_password update_password].each do |action|
        it { should be_able_to(action, case_worker) }
      end
    end

    context 'cannot allocate claims' do
      %i[new create].each do |action|
        it { should_not be_able_to(action, Allocation.new) }
      end
    end

    context 'can dismiss injection attempt errors' do
      it { should be_able_to(:dismiss, InjectionAttempt.new) }
    end

    context 'with user management' do
      it { is_expected.not_to be_able_to(:index, User) }
    end

    it { is_expected.to be_able_to(:index, CourtData) }
  end

  context 'with a case worker admin' do
    let(:case_worker) { create(:case_worker, :admin) }
    let(:user) { case_worker.user }

    %i[index archived show update].each do |action|
      it { should be_able_to(action, Claim::AdvocateClaim.new) }
    end

    context 'can view/download documents' do
      %i[show download].each do |action|
        it { should be_able_to(action, Document.new) }
      end
    end

    context 'can manage case workers' do
      %i[index show new create edit change_password update_password update destroy].each do |action|
        it { should be_able_to(action, CaseWorker.new) }
      end
    end

    context 'can allocate claims' do
      %i[new create].each do |action|
        it { should be_able_to(action, Allocation.new) }
      end
    end

    context 'can view management information' do
      [:view].each do |action|
        it { should be_able_to(action, :management_information) }
      end
    end

    context 'can dismiss injection attempt errors' do
      it { should be_able_to(:dismiss, InjectionAttempt.new) }
    end

    context 'with user management' do
      it { is_expected.not_to be_able_to(:index, User) }
    end

    it { is_expected.to be_able_to(:index, CourtData) }
  end

  context 'with a case worker provider manager' do
    let(:case_worker) { create(:case_worker, :provider_manager) }
    let(:user) { case_worker.user }

    context 'with a live external user' do
      let(:target) { create(:external_user) }

      it { is_expected.to be_able_to(:show, target) }
      it { is_expected.to be_able_to(:index, target) }
      it { is_expected.to be_able_to(:find, target) }
      it { is_expected.to be_able_to(:search, target) }
      it { is_expected.to be_able_to(:new, target) }
      it { is_expected.to be_able_to(:create, target) }
      it { is_expected.to be_able_to(:edit, target) }
      it { is_expected.to be_able_to(:update, target) }
      it { is_expected.to be_able_to(:change_password, target) }
      it { is_expected.to be_able_to(:update_password, target) }

      it { is_expected.not_to be_able_to(:destroy, target) }
      it { is_expected.not_to be_able_to(:confirmation, target) }
      it { is_expected.not_to be_able_to(:change_availability, target) }
      it { is_expected.not_to be_able_to(:update_availability, target) }
    end

    context 'with a softly deleted external user' do
      let(:target) { create(:external_user, :softly_deleted) }

      it { is_expected.not_to be_able_to(:show, target) }
      it { is_expected.not_to be_able_to(:edit, target) }
      it { is_expected.not_to be_able_to(:update, target) }
      it { is_expected.not_to be_able_to(:change_password, target) }
      it { is_expected.not_to be_able_to(:update_password, target) }
      it { is_expected.not_to be_able_to(:destroy, target) }
      it { is_expected.not_to be_able_to(:confirmation, target) }
      it { is_expected.not_to be_able_to(:change_availability, target) }
      it { is_expected.not_to be_able_to(:update_availability, target) }
    end

    context 'with a disabled external user' do
      let(:target) { create(:external_user, :disabled) }

      it { is_expected.not_to be_able_to(:show, target) }
      it { is_expected.not_to be_able_to(:edit, target) }
      it { is_expected.not_to be_able_to(:update, target) }
      it { is_expected.not_to be_able_to(:change_password, target) }
      it { is_expected.not_to be_able_to(:update_password, target) }
      it { is_expected.not_to be_able_to(:destroy, target) }
      it { is_expected.not_to be_able_to(:confirmation, target) }
      it { is_expected.not_to be_able_to(:change_availability, target) }
      it { is_expected.not_to be_able_to(:update_availability, target) }
    end

    context 'with user management' do
      it { is_expected.not_to be_able_to(:index, User) }
    end
  end

  context 'with a super admin' do
    let(:super_admin) { create(:super_admin) }
    let(:user) { super_admin.user }
    let(:other_super_admin) { create(:super_admin) }
    let(:external_user) { create(:external_user, provider:) }

    it { is_expected.to be_able_to(:update_settings, user) }
    it { is_expected.not_to be_able_to(:update_settings, another_user) }

    %i[show edit update change_password update_password].each do |action|
      it { is_expected.to be_able_to(action, super_admin) }
    end

    it_behaves_like 'user cannot', :other_super_admin, %i[show edit update change_password update_password]

    context 'with a provider' do
      let(:target) { create(:provider) }

      it { is_expected.not_to be_able_to(:new, target) }
      it { is_expected.not_to be_able_to(:create, target) }
      it { is_expected.not_to be_able_to(:edit, target) }
      it { is_expected.not_to be_able_to(:update, target) }
      it { is_expected.not_to be_able_to(:destroy, target) }

      it { is_expected.to be_able_to(:show, target) }
      it { is_expected.to be_able_to(:index, target) }
    end

    context 'with an external user' do
      let(:target) { create(:external_user) }

      it { is_expected.to be_able_to(:show, target) }
      it { is_expected.to be_able_to(:index, target) }
      it { is_expected.to be_able_to(:find, target) }
      it { is_expected.to be_able_to(:search, target) }
      it { is_expected.to be_able_to(:change_availability, target) }
      it { is_expected.to be_able_to(:update_availability, target) }

      it { is_expected.not_to be_able_to(:new, target) }
      it { is_expected.not_to be_able_to(:create, target) }
      it { is_expected.not_to be_able_to(:edit, target) }
      it { is_expected.not_to be_able_to(:update, target) }
      it { is_expected.not_to be_able_to(:change_password, target) }
      it { is_expected.not_to be_able_to(:update_password, target) }
      it { is_expected.not_to be_able_to(:destroy, target) }
    end

    context 'with user management' do
      it { is_expected.to be_able_to(:index, User) }
    end
  end
end
