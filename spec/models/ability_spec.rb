require 'rails_helper'
require 'cancan/matchers'

describe Ability do
  subject { Ability.new(user) }
  let(:user) { nil }

  context 'when not a signed in user' do
    it { should_not be_able_to(:create, Message.new) }
    it { should_not be_able_to(:index, UserMessageStatus) }
    it { should_not be_able_to(:update, UserMessageStatus.new) }
  end

  context 'when a signed in user' do
    let(:user) { create(:advocate).user }

    it { should be_able_to(:create, Message.new) }
    it { should be_able_to(:index, UserMessageStatus) }
    it { should be_able_to(:update, UserMessageStatus.new) }
  end

  context 'advocate' do
    let(:advocate) { create(:advocate) }
    let(:user) { advocate.user }

    [:index, :landing, :outstanding, :authorised, :new, :create].each do |action|
      it { should be_able_to(action, Claim) }
    end

    context 'can manage their own claims' do
      [:show, :edit, :update, :confirmation, :destroy].each do |action|
        it { should be_able_to(action, Claim.new(advocate: advocate)) }
      end
    end

    context 'cannot manage claims by another advocate' do
      let(:other_advocate) { create(:advocate) }

      [:show, :edit, :update, :confirmation, :destroy].each do |action|
        it { should_not be_able_to(action, Claim.new(advocate: other_advocate)) }
      end
    end

    context 'can view/download their own documents' do
      [:show, :download].each do |action|
        it { should be_able_to(action, Document.new(advocate: advocate)) }
      end
    end

    context 'cannot view/download another advocate\'s documents' do
      let(:other_advocate) { create(:advocate) }

      [:show, :download].each do |action|
        it { should_not be_able_to(action, Document.new(advocate: other_advocate)) }
      end
    end

    context 'cannot manage advocates' do
      [:show, :edit, :update, :destroy].each do |action|
        it { should_not be_able_to(action, Advocate.new(chamber: advocate.chamber)) }
      end
    end
  end

  context 'advocate admin' do
    let(:chamber) { create(:chamber) }
    let(:advocate) { create(:advocate, :admin, chamber: chamber) }
    let(:user) { advocate.user }

    [:index, :landing, :outstanding, :authorised, :new, :create].each do |action|
      it { should be_able_to(action, Claim) }
    end

    context 'can manage their own claims' do
      [:show, :edit, :update, :confirmation, :destroy].each do |action|
        it { should be_able_to(action, Claim.new(advocate: advocate)) }
      end
    end

    context 'can manage claims by another advocate in the same chamber' do
      let(:other_advocate) { create(:advocate, chamber: chamber) }

      [:show, :edit, :update, :confirmation, :destroy].each do |action|
        it { should be_able_to(action, Claim.new(advocate: other_advocate)) }
      end
    end

    context 'cannot manage claims by another advocate in a different chamber' do
      let(:other_advocate) { create(:advocate) }

      [:show, :edit, :update, :confirmation, :destroy].each do |action|
        it { should_not be_able_to(action, Claim.new(advocate: other_advocate)) }
      end
    end

    context 'can view/download their own documents' do
      [:show, :download].each do |action|
        it { should be_able_to(action, Document.new(advocate: advocate)) }
      end
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

    context 'can manage advocates in their chamber' do
      [:show, :edit, :update, :destroy].each do |action|
        it { should be_able_to(action, Advocate.new(chamber: chamber)) }
      end
    end

    context 'cannot manage advocates in a different chamber' do
      let(:other_chamber) { create(:chamber) }

      [:show, :edit, :update, :destroy].each do |action|
        it { should_not be_able_to(action, Advocate.new(chamber: other_chamber)) }
      end
    end
  end

  context 'case worker' do
    let(:case_worker) { create(:case_worker) }
    let(:user) { case_worker.user }

    [:index, :show].each do |action|
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
      [:index, :show, :new, :create, :edit, :allocate, :update, :destroy].each do |action|
        it { should_not be_able_to(action, CaseWorker.new) }
      end
    end
  end

  context 'case worker admin' do
    let(:case_worker) { create(:case_worker, :admin) }
    let(:user) { case_worker.user }

    [:index, :show, :update].each do |action|
      it { should be_able_to(action, Claim.new) }
    end

    context 'can view/download documents' do
      [:show, :download].each do |action|
        it { should be_able_to(action, Document.new) }
      end
    end

    context 'can manage case workers' do
      [:index, :show, :new, :create, :edit, :allocate, :update, :destroy].each do |action|
        it { should be_able_to(action, CaseWorker.new) }
      end
    end
  end
end
