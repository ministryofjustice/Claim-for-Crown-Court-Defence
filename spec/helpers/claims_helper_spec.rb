require 'rails_helper'

RSpec.shared_examples 'include unclaimed_fees message' do
  let(:unused_materials_fee) { create(:misc_fee_type, :miumu) }
  let(:another_fee) { create(:misc_fee_type, :miphc) }
  let(:eligible_fees) { [another_fee] }

  before { allow(claim).to receive(:eligible_misc_fee_types).and_return Array(eligible_fees) }

  context 'with one fee to be signposted' do
    let(:eligible_fees) { [unused_materials_fee, another_fee] }

    it { is_expected.to eq("'Unused materials (up to 3 hours)'") }

    context 'when unused material fees have already been claimed' do
      before do
        create(:misc_fee, fee_type: unused_materials_fee, claim:, quantity: 1)
        claim.reload
      end

      it { is_expected.to be_nil }
    end
  end

  context 'with a claim eligible for unused materials and additional preparation fees' do
    let(:additional_preparation_fee) { create(:misc_fee_type, :miapf) }
    let(:eligible_fees) { [unused_materials_fee, additional_preparation_fee, another_fee] }

    it { is_expected.to eq("'Unused materials (up to 3 hours)' and 'Additional preparation fee'") }

    context 'when unused material fees have already been claimed' do
      before do
        create(:misc_fee, fee_type: unused_materials_fee, claim:, quantity: 1)
        claim.reload
      end

      it { is_expected.to eq("'Additional preparation fee'") }
    end

    context 'when unused material fees and additional preparation fee have already been claimed' do
      before do
        create(:misc_fee, fee_type: unused_materials_fee, claim:, quantity: 1)
        create(:misc_fee, fee_type: additional_preparation_fee, claim:, quantity: 1)
        claim.reload
      end

      it { is_expected.to be_blank }
    end
  end

  context 'with a claim ineligible for unused materials and additional preparation fees' do
    it { is_expected.to be_blank }
  end
end

RSpec.describe ClaimsHelper do
  describe '#show_api_promo_to_user?' do
    helper do
      def current_user
        instance_double(User, setting?: api_promo_seen_setting)
      end
    end

    context 'user has not seen yet the promo' do
      let(:api_promo_seen_setting) { nil }

      it 'returns true' do
        expect(show_api_promo_to_user?).to be_truthy
      end
    end

    context 'user has seen the promo' do
      let(:api_promo_seen_setting) { '1' }

      it 'returns false' do
        expect(show_api_promo_to_user?).to be_falsey
      end
    end
  end

  describe '#show_message_controls?' do
    subject(:subj_show_message_controls?) { show_message_controls?(claim) }

    let(:claim) { build(:claim, state:) }

    RSpec.configure do |c|
      c.include ApplicationHelper
    end

    helper do
      def current_user
        instance_double(User, persona:)
      end
    end

    context 'for case_worker' do
      let(:persona) { create(:case_worker) }

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
      let(:persona) { create(:external_user) }

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

      it { is_expected.to be_falsey }
    end
  end

  describe '#messaging_permitted?' do
    subject { messaging_permitted?(message) }

    let(:claim) { build(:claim, state:) }
    let(:message) { build(:message, claim:, claim_action:) }
    let(:claim_action) { nil }

    helper do
      def current_user
        instance_double(User, persona:)
      end
    end

    context 'for case_worker' do
      let(:persona) { create(:case_worker) }

      context 'for a claim with claim actions' do
        let(:state) { 'rejected' }
        let(:claim_action) { 'Request written reasons' }

        it { is_expected.to be_truthy }
      end

      %w[submitted allocated authorised part_authorised rejected refused redetermination awaiting_written_reasons].each do |state|
        context "when claim state is #{state}" do
          let(:state) { state }

          it { is_expected.to be_falsey }
        end
      end
    end

    context 'for external_user' do
      let(:persona) { create(:external_user) }

      context 'for a claim with claim actions' do
        let(:state) { 'rejected' }
        let(:claim_action) { 'Request written reasons' }

        it { is_expected.to be_truthy }
      end

      context 'for non redeterminable claim states' do
        let(:claim) { build(:claim, state:) }

        %w[submitted allocated redetermination awaiting_written_reasons].each do |state|
          context "when claim state is #{state}" do
            let(:state) { state }

            it { is_expected.to be_truthy }
          end
        end
      end

      context 'for redeterminable claim states' do
        let(:claim) { build(:claim, state:) }

        %w[authorised part_authorised rejected refused].each do |state|
          context "when claim state is #{state}" do
            let(:state) { state }

            it { is_expected.to be_falsey }
          end
        end
      end
    end
  end

  describe '#fee_shared_headings' do
    subject(:headings) { fee_shared_headings(claim, 'external_users.claims.misc_fees') }

    let(:claim) { build(:claim, :with_graduated_fee_case) }

    include_examples 'include unclaimed_fees message' do
      subject { headings[:unclaimed_fees] }
    end

    context 'when fees_calculator_html is provided' do
      subject(:headings) { fee_shared_headings(claim, 'test.scope', 'some custom html') }

      it { expect(headings[:fees_calculator_html]).to eq 'some custom html' }
    end

    context 'when fees_calculator_html is not provided' do
      it { expect(headings[:fees_calculator_html]).to be_nil }
    end
  end

  describe '#misc_fees_summary_locals' do
    subject(:locals) { misc_fees_summary_locals(claim) }

    let(:claim) { build(:claim, :with_graduated_fee_case) }

    include_examples 'include unclaimed_fees message' do
      subject { locals[:unclaimed_fees] }
    end
  end

  describe '#unclaimed_fees_list' do
    subject { unclaimed_fees_list(claim) }

    let(:claim) { build(:claim, :with_graduated_fee_case) }

    include_examples 'include unclaimed_fees message'
  end

  describe '#display_elected_not_proceeded_signpost?' do
    subject { display_elected_not_proceeded_signpost?(claim) }

    let(:claim) { build(:claim) }

    context 'with a final claim' do
      before { allow(claim).to receive(:final?).and_return true }

      context 'when the date is on or after the start of the CLAIR fee scheme' do
        before { travel_to(Settings.lgfs_scheme_10_clair_release_date.end_of_day) }

        it { is_expected.to be_truthy }
      end

      context 'when the date is before the start of the CLAIR fee scheme' do
        before { travel_to(Settings.lgfs_scheme_10_clair_release_date - 1) }

        it { is_expected.to be_falsey }
      end
    end

    context 'with a non-final claim' do
      before { allow(claim).to receive(:final?).and_return false }

      context 'when the date is on or after the start of the CLAIR fee scheme' do
        before { travel_to(Settings.lgfs_scheme_10_clair_release_date.end_of_day) }

        it { is_expected.to be_falsey }
      end

      context 'when the date is before the start of the CLAIR fee scheme' do
        before { travel_to(Settings.lgfs_scheme_10_clair_release_date - 1) }

        it { is_expected.to be_falsey }
      end
    end
  end
end
