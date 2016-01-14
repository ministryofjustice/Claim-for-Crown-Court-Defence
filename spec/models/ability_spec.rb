require 'rails_helper'
require 'cancan/matchers'

describe Ability do
  subject { Ability.new(user) }
  let(:user) { nil }

  context 'when not a signed in user' do
    it { should_not be_able_to(:create, Message.new) }
    it { should_not be_able_to(:download_attachment, Message.new) }
    it { should_not be_able_to(:index, UserMessageStatus) }
    it { should_not be_able_to(:update, UserMessageStatus.new) }
    it { should_not be_able_to(:create, Document.new) }
  end

  context 'when a signed in user' do
    let(:user) { create(:external_user).user }

    it { should be_able_to(:create, Message.new) }
    it { should be_able_to(:download_attachment, Message.new) }
    it { should be_able_to(:download_attachment, Message.new) }
    it { should be_able_to(:index, UserMessageStatus) }
    it { should be_able_to(:update, UserMessageStatus.new) }
  end

  context 'external_user' do
    let(:external_user) { create(:external_user) }
    let(:provider) { external_user.provider }
    let(:user) { external_user.user }

    [:create].each do |action|
      it { should be_able_to(action, ClaimIntention) }
    end

    [:index, :outstanding, :authorised, :archived, :new, :create].each do |action|
      it { should be_able_to(action, Claim) }
    end

    context 'can manage their own claims' do
      [:show, :show_message_controls, :edit, :update, :confirmation, :clone_rejected, :destroy].each do |action|
        it { should be_able_to(action, Claim.new(external_user: external_user)) }
      end
    end

    context 'cannot manage claims by another external_user' do
      let(:other_external_user) { create(:external_user) }

      [:show, :show_message_controls, :edit, :update, :confirmation, :clone_rejected, :destroy].each do |action|
        it { should_not be_able_to(action, Claim.new(external_user: other_external_user)) }
      end
    end

    context 'can view/download their own documents' do
      [:show, :download].each do |action|
        it { should be_able_to(action, Document.new(external_user: external_user)) }
      end
    end

    context 'can index and create documents' do
      [:index, :create].each do |action|
        it { should be_able_to(action, Document.new(external_user: external_user)) }
      end
    end

    context 'can destroy own documents' do
      it { should be_able_to(:destroy, Document.new(external_user: external_user)) }
    end

    context 'cannot view/download another external_user\'s documents' do
      let(:other_external_user) { create(:external_user) }

      [:show, :download].each do |action|
        it { should_not be_able_to(action, Document.new(external_user: other_external_user)) }
      end
    end

    context 'cannot destroy another\'s documents' do
      let(:other_external_user) { create(:external_user) }

      it { should_not be_able_to(:destroy, Document.new(external_user: other_external_user)) }
    end

    context 'cannot manage external_user:s' do
      [:show, :edit, :update, :destroy, :change_password, :update_password].each do |action|
        it { should_not be_able_to(action, ExternalUser.new(provider: external_user.provider)) }
      end
    end

    context 'can view profile and change own password' do
      [:show, :change_password, :update_password].each do |action|
        it { should be_able_to(action, external_user) }
      end
    end

    context 'cannot manage their provider' do
      [:show, :edit, :update, :regenerate_api_key].each do |action|
        it { should_not be_able_to(action, provider) }
      end
    end

    context 'cannot manage other providers' do
      let(:other_provider) { create(:provider) }
      [:show, :edit, :update, :regenerate_api_key].each do |action|
        it { should_not be_able_to(action, other_provider) }
      end
    end

  end

  context 'external_user admin' do
    let(:provider) { create(:provider) }
    let(:external_user) { create(:external_user, :admin, provider: provider) }
    let(:user) { external_user.user }

    [:create].each do |action|
      it { should be_able_to(action, ClaimIntention) }
    end

    [:index, :outstanding, :authorised, :archived, :new, :create].each do |action|
      it { should be_able_to(action, Claim) }
    end

    context 'can manage their own claims' do
      [:show, :show_message_controls, :edit, :update, :confirmation, :clone_rejected, :destroy].each do |action|
        it { should be_able_to(action, Claim.new(external_user: external_user)) }
      end
    end

    context 'can manage claims by another external_user in the same provider' do
      let(:other_external_user) { create(:external_user, provider: provider) }

      [:show, :show_message_controls, :edit, :update, :confirmation, :clone_rejected, :destroy].each do |action|
        it { should be_able_to(action, Claim.new(external_user: other_external_user)) }
      end
    end

    context 'can manage their provider' do
      [:show, :edit, :update, :regenerate_api_key].each do |action|
        it { should be_able_to(action, provider) }
      end
    end

    context 'cannot manage other providers' do
      let(:other_provider) { create(:provider) }
      [:show, :edit, :update, :regenerate_api_key].each do |action|
        it { should_not be_able_to(action, other_provider) }
      end
    end

    context 'cannot manage claims by another external_user with a different provider' do
      let(:other_external_user) { create(:external_user) }

      [:show, :show_message_controls, :edit, :update, :confirmation, :clone_rejected, :destroy].each do |action|
        it { should_not be_able_to(action, Claim.new(external_user: other_external_user)) }
      end
    end

    context 'can view/download their own documents' do
      [:show, :download].each do |action|
        it { should be_able_to(action, Document.new(external_user: external_user)) }
      end
    end

    context 'can index and create documents' do
      [:index, :create].each do |action|
        it { should be_able_to(action, Document.new(external_user: external_user)) }
      end
    end

    context 'can destroy own documents' do
      it { should be_able_to(:destroy, Document.new(external_user: external_user)) }
    end

    context 'can view/download documents by an external_user in the same provider' do
      let(:other_external_user) { create(:external_user, provider: provider) }

      [:show, :download].each do |action|
        it { should be_able_to(action, Document.new(external_user: other_external_user)) }
      end
    end

    context 'cannot view/`download another external_user\'s documents' do
      let(:other_external_user) { create(:external_user) }

      [:show, :download].each do |action|
        it { should_not be_able_to(action, Document.new(external_user: other_external_user)) }
      end
    end

    context 'cannot destroy another\'s documents' do
      let(:other_external_user) { create(:external_user) }

      it { should_not be_able_to(:destroy, Document.new(external_user: other_external_user)) }
    end

    context 'can manage external_users in their provider' do
      [:show, :edit, :update, :destroy, :change_password, :update_password].each do |action|
        it { should be_able_to(action, ExternalUser.new(provider: provider)) }
      end
    end

    context 'cannot manage external_users in a different provider' do
      let(:other_provider) { create(:provider) }

      [:show, :edit, :update, :destroy, :change_password, :update_password].each do |action|
        it { should_not be_able_to(action, ExternalUser.new(provider: other_provider)) }
      end
    end
  end

  context 'case worker' do
    let(:case_worker) { create(:case_worker) }
    let(:user) { case_worker.user }

    [:index, :archived, :show, :show_message_controls].each do |action|
      it { should be_able_to(action, Claim.new) }
    end

    context 'can update claim when assigned to claim' do
      let(:claim) { create(:claim) }
      before { case_worker.claims << claim }

      it { should be_able_to(:update, claim) }
    end

    context 'cannot update claim when not assigned to claim' do
      it { should_not be_able_to(:update, Claim.new) }
    end

    context 'can view/download documents' do
      [:show, :download].each do |action|
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
      [:index, :show, :new, :create, :edit, :change_password, :update_password, :allocate, :update, :destroy].each do |action|
        it { should_not be_able_to(action, CaseWorker.new) }
      end
    end

    context 'can view their own profile and change password' do
      [:show, :change_password, :update_password].each do |action|
        it { should be_able_to(action, case_worker) }
      end
    end

    context 'cannot allocate claims' do
      [:new, :create].each do |action|
        it { should_not be_able_to(action, Allocation.new) }
      end
    end
  end

  context 'case worker admin' do
    let(:case_worker) { create(:case_worker, :admin) }
    let(:user) { case_worker.user }

    [:index, :archived, :show, :update].each do |action|
      it { should be_able_to(action, Claim.new) }
    end

    context 'can view/download documents' do
      [:show, :download].each do |action|
        it { should be_able_to(action, Document.new) }
      end
    end

    context 'can manage case workers' do
      [:index, :show, :new, :create, :edit, :change_password, :update_password, :allocate, :update, :destroy].each do |action|
        it { should be_able_to(action, CaseWorker.new) }
      end
    end

    context 'can allocate claims' do
      [:new, :create].each do |action|
        it { should be_able_to(action, Allocation.new) }
      end
    end

    context 'can view management information' do
      [:view].each do |action|
        it { should be_able_to(action, :management_information) }
      end
    end
  end

  context 'super admin' do

    let(:super_admin)       { create(:super_admin) }
    let(:user)              { super_admin.user }
    let(:other_super_admin) { create(:super_admin) }
    let(:provider)          { create(:provider) }
    let(:other_provider)    { create(:provider) }
    let(:external_user)          { create(:external_user, provider: provider)}
    let(:other_external_user)    { create(:external_user, provider: other_provider)}

    context 'can manage any provider' do
      [:show, :index, :new, :create, :edit, :update].each do |action|
        it { should be_able_to(action, provider) }
      end
    end

    context 'cannot destroy providers' do
      [:destroy].each do |action|
        it { should_not be_able_to(action, provider) }
      end
    end

    context 'can view and change own details' do
      [:show, :edit, :update, :change_password, :update_password].each do |action|
        it { should be_able_to(action, super_admin) }
      end
    end

    context 'cannot view or change other super admins details' do
      [:show, :edit, :update, :change_password, :update_password].each do |action|
        it { should_not be_able_to(action, other_super_admin) }
      end
    end

    context 'can view, create and change any external_users details' do
      [:show, :edit, :update, :new, :create, :change_password, :update_password].each do |action|
        it { should be_able_to(action, external_user) }
        it { should be_able_to(action, other_external_user) }
      end
    end

    context 'cannot destroy external_users' do
      [:destroy].each do |action|
        it { should_not be_able_to(action, external_user) }
      end
    end

  end


end
