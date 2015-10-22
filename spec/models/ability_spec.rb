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
    it { should_not be_able_to(:new, Feedback.new) }
    it { should_not be_able_to(:create, Feedback.new) }
  end

  context 'when a signed in user' do
    let(:user) { create(:advocate).user }

    it { should be_able_to(:create, Message.new) }
    it { should be_able_to(:download_attachment, Message.new) }
    it { should be_able_to(:index, UserMessageStatus) }
    it { should be_able_to(:update, UserMessageStatus.new) }
    it { should be_able_to(:new, Feedback.new) }
    it { should be_able_to(:create, Feedback.new) }
  end

  context 'advocate' do
    let(:advocate) { create(:advocate) }
    let(:chamber) { advocate.chamber }
    let(:user) { advocate.user }

    [:create].each do |action|
      it { should be_able_to(action, ClaimIntention) }
    end

    [:index, :outstanding, :authorised, :archived, :new, :create].each do |action|
      it { should be_able_to(action, Claim) }
    end

    context 'can manage their own claims' do
      [:show, :edit, :update, :confirmation, :clone_rejected, :destroy].each do |action|
        it { should be_able_to(action, Claim.new(advocate: advocate)) }
      end
    end

    context 'cannot manage claims by another advocate' do
      let(:other_advocate) { create(:advocate) }

      [:show, :edit, :update, :confirmation, :clone_rejected, :destroy].each do |action|
        it { should_not be_able_to(action, Claim.new(advocate: other_advocate)) }
      end
    end

    context 'can view/download their own documents' do
      [:show, :download].each do |action|
        it { should be_able_to(action, Document.new(advocate: advocate)) }
      end
    end

    context 'can index and create documents' do
      [:index, :create].each do |action|
        it { should be_able_to(action, Document.new(advocate: advocate)) }
      end
    end

    context 'can destroy own documents' do
      it { should be_able_to(:destroy, Document.new(advocate: advocate)) }
    end

    context 'cannot view/download another advocate\'s documents' do
      let(:other_advocate) { create(:advocate) }

      [:show, :download].each do |action|
        it { should_not be_able_to(action, Document.new(advocate: other_advocate)) }
      end
    end

    context 'cannot destroy another\'s documents' do
      let(:other_advocate) { create(:advocate) }

      it { should_not be_able_to(:destroy, Document.new(advocate: other_advocate)) }
    end

    context 'cannot manage advocates' do
      [:show, :edit, :update, :destroy, :change_password, :update_password].each do |action|
        it { should_not be_able_to(action, Advocate.new(chamber: advocate.chamber)) }
      end
    end

    context 'can view profile and change own password' do
      [:show, :change_password, :update_password].each do |action|
        it { should be_able_to(action, advocate) }
      end
    end

    context 'cannot manage their chamber' do
      [:show, :edit, :update, :regenerate_api_key].each do |action|
        it { should_not be_able_to(action, chamber) }
      end
    end

    context 'cannot manage other chambers' do
      let(:other_chamber) { create(:chamber) }
      [:show, :edit, :update, :regenerate_api_key].each do |action|
        it { should_not be_able_to(action, other_chamber) }
      end
    end

  end

  context 'advocate admin' do
    let(:chamber) { create(:chamber) }
    let(:advocate) { create(:advocate, :admin, chamber: chamber) }
    let(:user) { advocate.user }

    [:create].each do |action|
      it { should be_able_to(action, ClaimIntention) }
    end

    [:index, :outstanding, :authorised, :archived, :new, :create].each do |action|
      it { should be_able_to(action, Claim) }
    end

    context 'can manage their own claims' do
      [:show, :edit, :update, :confirmation, :clone_rejected, :destroy].each do |action|
        it { should be_able_to(action, Claim.new(advocate: advocate)) }
      end
    end

    context 'can manage claims by another advocate in the same chamber' do
      let(:other_advocate) { create(:advocate, chamber: chamber) }

      [:show, :edit, :update, :confirmation, :clone_rejected, :destroy].each do |action|
        it { should be_able_to(action, Claim.new(advocate: other_advocate)) }
      end
    end

    context 'can manage their chamber' do
      [:show, :edit, :update, :regenerate_api_key].each do |action|
        it { should be_able_to(action, chamber) }
      end
    end

    context 'cannot manage other chambers' do
      let(:other_chamber) { create(:chamber) }
      [:show, :edit, :update, :regenerate_api_key].each do |action|
        it { should_not be_able_to(action, other_chamber) }
      end
    end

    context 'cannot manage claims by another advocate in a different chamber' do
      let(:other_advocate) { create(:advocate) }

      [:show, :edit, :update, :confirmation, :clone_rejected, :destroy].each do |action|
        it { should_not be_able_to(action, Claim.new(advocate: other_advocate)) }
      end
    end

    context 'can view/download their own documents' do
      [:show, :download].each do |action|
        it { should be_able_to(action, Document.new(advocate: advocate)) }
      end
    end

    context 'can index and create documents' do
      [:index, :create].each do |action|
        it { should be_able_to(action, Document.new(advocate: advocate)) }
      end
    end

    context 'can destroy own documents' do
      it { should be_able_to(:destroy, Document.new(advocate: advocate)) }
    end

    context 'can view/download documents by an advocate in the same chamber' do
      let(:other_advocate) { create(:advocate, chamber: chamber) }

      [:show, :download].each do |action|
        it { should be_able_to(action, Document.new(advocate: other_advocate)) }
      end
    end

    context 'cannot view/download another advocate\'s documents' do
      let(:other_advocate) { create(:advocate) }

      [:show, :download].each do |action|
        it { should_not be_able_to(action, Document.new(advocate: other_advocate)) }
      end
    end

    context 'cannot destroy another\'s documents' do
      let(:other_advocate) { create(:advocate) }

      it { should_not be_able_to(:destroy, Document.new(advocate: other_advocate)) }
    end

    context 'can manage advocates in their chamber' do
      [:show, :edit, :update, :destroy, :change_password, :update_password].each do |action|
        it { should be_able_to(action, Advocate.new(chamber: chamber)) }
      end
    end

    context 'cannot manage advocates in a different chamber' do
      let(:other_chamber) { create(:chamber) }

      [:show, :edit, :update, :destroy, :change_password, :update_password].each do |action|
        it { should_not be_able_to(action, Advocate.new(chamber: other_chamber)) }
      end
    end
  end

  context 'case worker' do
    let(:case_worker) { create(:case_worker) }
    let(:user) { case_worker.user }

    [:index, :archived, :show].each do |action|
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
  end
end
