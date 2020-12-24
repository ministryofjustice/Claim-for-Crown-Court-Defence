require 'rails_helper'

RSpec.describe ClaimsHelper do
  describe '#claim_allocation_checkbox_helper' do
    let(:case_worker) { double CaseWorker }
    let(:claim) { double Claim }

    before(:each) do
      allow(claim).to receive(:id).and_return(66)
      allow(case_worker).to receive(:id).and_return(888)
    end

    it 'should produce the html for a checked checkbox if the claim is allocated to the case worker' do
      expect(claim).to receive(:is_allocated_to_case_worker?).with(case_worker).and_return(true)
      expected_html = %q{<input checked="checked" id="case_worker_claim_ids_66" name="case_worker[claim_ids][]" type="checkbox" value="66">}
      expect(claim_allocation_checkbox_helper(claim, case_worker)).to eq expected_html
    end

    it 'should produce the html for a un-checked checkbox if the claim is not allocated to the case worker' do
      expect(claim).to receive(:is_allocated_to_case_worker?).with(case_worker).and_return(false)
      expected_html = %q{<input  id="case_worker_claim_ids_66" name="case_worker[claim_ids][]" type="checkbox" value="66">}
      expect(claim_allocation_checkbox_helper(claim, case_worker)).to eq expected_html
    end
  end

  describe '#includes_state?' do
    let(:only_allocated_claims) { create_list(:allocated_claim, 5) }

    it 'returns true if state included as array' do
      states_as_arr = ['draft','allocated']
      expect(includes_state?(only_allocated_claims,states_as_arr)).to eql(true)
    end

    it 'returns true if state included as comma delimited string' do
      states_as_comma_delimited_string = 'draft,allocated'
      expect(includes_state?(only_allocated_claims,states_as_comma_delimited_string)).to eql(true)
    end

    it 'returns false if state NOT included' do
      invalid_states = 'draft,submitted'
      expect(includes_state?(only_allocated_claims,invalid_states)).to eql(false)
    end
  end

  describe '#display_downtime_warning?' do
    subject { helper.display_downtime_warning? }

    before do
      allow(Settings).to receive(:downtime_warning_enabled?).and_return(downtime_warning_enabled)
      allow(Settings).to receive(:downtime_warning_date).and_return(downtime_warning_date)
      allow(helper).to receive(:current_user).and_return(current_user)
    end

    context 'feature flag enabled' do
      let(:downtime_warning_enabled) { true }

      around do |example|
        travel_to(curr_date) do
          example.run
        end
      end

      context 'current date is on or before downtime_warning_date' do
        let(:curr_date) { Date.parse('2019-11-20') }
        let(:downtime_warning_date) { '2019-11-20' }

        context 'no current user' do
          let(:current_user) { nil }
          it { is_expected.to be false }
        end

        context 'current user is an external user' do
          let(:current_user) { create(:external_user, :advocate).user }
          it { is_expected.to be true }
        end

        context 'current user is case worker' do
          let(:current_user) { create(:case_worker).user }
          it { is_expected.to be true }
        end
      end

      context 'current date is after downtime_warning_date' do
        let(:curr_date) { Date.parse('2019-11-21') }
        let(:downtime_warning_date) { '2019-11-20' }

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

    context 'feature flag disabled' do
      let(:downtime_warning_enabled) { false }

      context 'when date is on or before downtime_warning_date' do
        let(:curr_date) { Date.parse('2019-11-20') }
        let(:downtime_warning_date) { '2019-11-20' }

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

  describe '#show_api_promo_to_user?' do
    helper do
      def current_user
        instance_double(User, setting?: api_promo_seen_setting)
      end
    end

    context 'user has not seen yet the promo' do
      let(:api_promo_seen_setting) { nil }

      it 'should return true' do
        expect(show_api_promo_to_user?).to be_truthy
      end
    end

    context 'user has seen the promo' do
      let(:api_promo_seen_setting) { '1' }

      it 'should return false' do
        expect(show_api_promo_to_user?).to be_falsey
      end
    end
  end

  describe '#show_message_controls?' do
    subject(:subj_show_message_controls?) { show_message_controls?(claim) }
    require 'application_helper'
    let(:claim) { build :claim, state: state }

    RSpec.configure do |c|
      c.include ApplicationHelper
    end

    helper do
      def current_user
        instance_double(User, persona: persona)
      end
    end

    context 'for case_worker' do
      let(:persona) { create :case_worker }

      %w[submitted allocated authorised part_authorised rejected refused redetermination awaiting_written_reasons].each do |state|
        context "when claim state is #{state}" do
          let(:state) { state }

          it { is_expected.to be_truthy }
        end
      end

      %w[draft].each do |state|
        context "when claim state is #{state}" do
          let(:state) { state }

          it { is_expected.to be_falsey }
        end
      end
    end

    context 'for external_user' do
      let(:persona) { create :external_user }

      %w[submitted allocated part_authorised refused authorised redetermination awaiting_written_reasons].each do |state|
        context "when claim state is #{state}" do
          let(:state) { state }

          it { is_expected.to be_truthy }
        end
      end

      %w[draft rejected archived_pending_delete].each do |state|
        context "when claim state is #{state}" do
          let(:state) { state }

          it { is_expected.to be_falsey }
        end
      end
    end

    context 'for user with invalid persona' do
      let(:persona) { nil }
      let(:state) { 'submitted' }

      it { is_expected. to be_falsey }
    end
  end

  describe '#messaging_permitted?' do
    subject { messaging_permitted?(message) }

    let(:claim) { build :claim, state: state }
    let(:message) { build(:message, claim: claim, claim_action: claim_action) }
    let(:claim_action) { nil }

    helper do
      def current_user
        instance_double(User, persona: persona)
      end
    end

    context 'for case_worker' do
      let(:persona) { create :case_worker }

      context 'for a claim with claim actions' do
        let(:state) { 'rejected' }
        let(:claim_action) { 'Request written reasons' }

        it { is_expected. to be_truthy }
      end

      %w[submitted allocated authorised part_authorised rejected refused redetermination awaiting_written_reasons].each do |state|
        context "when claim state is #{state}" do
          let(:state) { state }

          it { is_expected. to be_falsey }
        end
      end
    end

    context 'for external_user' do
      let(:persona) { create :external_user }

      context 'for a claim with claim actions' do
        let(:state) { 'rejected' }
        let(:claim_action) { 'Request written reasons' }

        it { is_expected. to be_truthy }
      end

      context 'for non redeterminable claim states' do
        let(:claim) { build :claim, state: state }

        %w[submitted allocated redetermination awaiting_written_reasons].each do |state|
          context "when claim state is #{state}" do
            let(:state) { state }

            it { is_expected. to be_truthy }
          end
        end
      end

      context 'for redeterminable claim states' do
        let(:claim) { build :claim, state: state }

        %w[authorised part_authorised rejected refused].each do |state|
          context "when claim state is #{state}" do
            let(:state) { state }

            it { is_expected. to be_falsey }
          end
        end
      end
    end
  end
end
