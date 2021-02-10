require 'rails_helper'

describe ApplicationHelper do
  describe '#present' do
    let(:claim) { create(:advocate_claim) }

    it 'returns a <Classname>Presenter instance' do
      expect(present(claim)).to be_a Claim::BaseClaimPresenter
    end

    it 'yields a <Classname>Presenter Class' do
      expect { |b| present(claim, &b) }.to yield_with_args(Claim::BaseClaimPresenter)
    end
  end

  describe '#present_collection' do
    let(:claims) { create_list(:claim, 2) }

    it 'returns a collection of <Classname>Presenter instances' do
      present_collection(claims).each do |claim|
        expect(claim).to be_instance_of Claim::AdvocateClaimPresenter
      end
    end

    it 'yields a collection of <Classname>Presenter Class instances' do
      expect { |block| present_collection(claims, &block) }.to yield_with_args([Claim::BaseClaimPresenter, Claim::BaseClaimPresenter])
    end
  end

  describe '#user_requires_scheme_column?' do
    let(:admin)     { create(:external_user, :agfs_lgfs_admin) }
    let(:advocate)  { create(:external_user, :advocate) }
    let(:litigator) { create(:external_user, :litigator) }

    it 'returns true for those users that could have AGFS and LGFS claims' do
      allow(helper).to receive(:current_user).and_return(admin.user)
      expect(helper.user_requires_scheme_column?).to be true
    end

    it 'returns false for users that only handle AGFS claims' do
      allow(helper).to receive(:current_user).and_return(advocate.user)
      expect(helper.user_requires_scheme_column?).to be false
    end

    it 'returns true for users that only handle LGFS claims' do
      allow(helper).to receive(:current_user).and_return(litigator.user)
      expect(helper.user_requires_scheme_column?).to be true
    end
  end

  describe '#cp' do
    subject(:cp) { helper.cp(path_with_params) }

    let(:path) { 'test' }
    let(:path_with_params) { path }

    context 'when the current request path matches that passed in' do
      before { controller.request.path = path }

      it { is_expected.to eql 'current' }

      context 'when then the tab param is set' do
        before { controller.request.GET[:tab] = 'also_test' }

        context 'and matches' do
          let(:path_with_params) { 'test?tab=also_test' }

          it { is_expected.to eql 'current' }
        end

        context 'and does not match' do
          let(:path_with_params) { 'test?tab=still_not_a_test' }

          it { is_expected.to be_nil }
        end
      end
    end

    context 'when the current request path does not match the one passed in' do
      before { controller.request.path = 'not_a_test' }

      it { is_expected.to be_nil }
    end
  end
end
