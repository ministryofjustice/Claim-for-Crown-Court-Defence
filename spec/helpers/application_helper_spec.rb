require 'rails_helper'

RSpec.describe ApplicationHelper do
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
      expect(present_collection(claims)).to all be_instance_of Claim::AdvocateClaimPresenter
    end

    it 'yields a collection of <Classname>Presenter Class instances' do
      expect do |block|
        present_collection(claims, &block)
      end.to yield_with_args([Claim::BaseClaimPresenter, Claim::BaseClaimPresenter])
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

      it { is_expected.to be_truthy }

      context 'when then the tab param is set' do
        before { controller.request.GET[:tab] = 'also_test' }

        context 'and matches' do
          let(:path_with_params) { 'test?tab=also_test' }

          it { is_expected.to be_truthy }
        end

        context 'and does not match' do
          let(:path_with_params) { 'test?tab=still_not_a_test' }

          it { is_expected.to be_falsey }
        end
      end
    end

    context 'when the current request path does not match the one passed in' do
      before { controller.request.path = 'not_a_test' }

      it { is_expected.to be_falsey }
    end
  end

  describe '#display_downtime_warning?' do
    subject { helper.display_downtime_warning? }

    before do
      allow(Settings).to receive_messages(downtime_warning_enabled?: downtime_warning_enabled, downtime_warning_date:)
      allow(helper).to receive_messages(current_user:, on_home_page?: true)
    end

    context 'feature flag enabled' do
      let(:downtime_warning_enabled) { true }

      before { travel_to(curr_date) }

      context 'when current date is on or before downtime_warning_date' do
        let(:curr_date) { Date.parse('2021-05-26') }
        let(:downtime_warning_date) { '2021-05-26' }

        context 'when no current user' do
          let(:current_user) { nil }

          it { is_expected.to be false }
        end

        context 'when current user is an external user' do
          let(:current_user) { create(:external_user, :advocate).user }

          it { is_expected.to be true }
        end

        context 'when current user is case worker' do
          let(:current_user) { create(:case_worker).user }

          it { is_expected.to be true }
        end
      end

      context 'when current date is after downtime_warning_date' do
        let(:curr_date) { Date.parse('2021-05-27') }
        let(:downtime_warning_date) { '2021-05-26' }

        context 'no current user' do
          let(:current_user) { nil }

          it { is_expected.to be false }
        end

        context 'current user is an external user' do
          let(:current_user) { create(:external_user, :advocate).user }

          it { is_expected.to be false }
        end

        context 'current user is case worker' do
          let(:current_user) { create(:case_worker).user }

          it { is_expected.to be false }
        end
      end

      context 'when user on a home page' do
        let(:curr_date) { Date.parse('2021-05-26') }
        let(:downtime_warning_date) { '2021-05-26' }
        let(:current_user) { create(:external_user).user }

        before { allow(helper).to receive(:on_home_page?).and_return(true) }

        it { is_expected.to be_truthy }
      end

      context 'when user NOT on a home page' do
        let(:curr_date) { Date.parse('2021-05-26') }
        let(:downtime_warning_date) { '2021-05-26' }
        let(:current_user) { create(:external_user).user }

        before { allow(helper).to receive(:on_home_page?).and_return(false) }

        it { is_expected.to be_falsey }
      end
    end

    context 'feature flag disabled' do
      let(:downtime_warning_enabled) { false }

      context 'when date is on or before downtime_warning_date' do
        let(:curr_date) { Date.parse('2021-05-26') }
        let(:downtime_warning_date) { '2021-05-26' }

        context 'no current user' do
          let(:current_user) { nil }

          it { is_expected.to be false }
        end

        context 'current user is an external user' do
          let(:current_user) { create(:external_user, :advocate).user }

          it { is_expected.to be false }
        end

        context 'current user is case worker' do
          let(:current_user) { create(:case_worker).user }

          it { is_expected.to be false }
        end
      end
    end
  end

  describe '#current_user_is_caseworker?' do
    subject { helper.current_user_is_caseworker? }

    before { sign_in user.user }

    context 'when not logged in' do
      let(:user) { create(:case_worker) }

      before { sign_out user.user }

      it { is_expected.to be_falsey }
    end

    context 'when logged in as a case worker' do
      let(:user) { create(:case_worker) }

      it { is_expected.to be_truthy }
    end

    context 'when logged in as an external user' do
      let(:user) { create(:external_user) }

      it { is_expected.to be_falsey }
    end
  end

  describe '#current_user_is_external_user?' do
    subject { helper.current_user_is_external_user? }

    before { sign_in user.user }

    context 'when not logged in' do
      let(:user) { create(:external_user) }

      before { sign_out user.user }

      it { is_expected.to be_falsey }
    end

    context 'when logged in as a case worker' do
      let(:user) { create(:case_worker) }

      it { is_expected.to be_falsey }
    end

    context 'when logged in as an external user' do
      let(:user) { create(:external_user) }

      it { is_expected.to be_truthy }
    end
  end
end
