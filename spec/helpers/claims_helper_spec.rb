require 'rails_helper'

RSpec.describe ClaimsHelper do
  describe '#claim_allocation_checkbox_helper' do
    let(:case_worker) { double CaseWorker }
    let(:claim) { double Claim }

    before do
      allow(claim).to receive(:id).and_return(66)
      allow(case_worker).to receive(:id).and_return(888)
    end

    it 'produces the html for a checked checkbox if the claim is allocated to the case worker' do
      expect(claim).to receive(:is_allocated_to_case_worker?).with(case_worker).and_return(true)
      expected_html = '<input checked="checked" id="case_worker_claim_ids_66" name="case_worker[claim_ids][]" type="checkbox" value="66">'
      expect(claim_allocation_checkbox_helper(claim, case_worker)).to eq expected_html
    end

    it 'produces the html for a un-checked checkbox if the claim is not allocated to the case worker' do
      expect(claim).to receive(:is_allocated_to_case_worker?).with(case_worker).and_return(false)
      expected_html = '<input  id="case_worker_claim_ids_66" name="case_worker[claim_ids][]" type="checkbox" value="66">'
      expect(claim_allocation_checkbox_helper(claim, case_worker)).to eq expected_html
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

    require 'application_helper'
    let(:claim) { build :claim, state: }

    RSpec.configure do |c|
      c.include ApplicationHelper
    end

    helper do
      def current_user
        instance_double(User, persona:)
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

      it { is_expected.to be_falsey }
    end
  end

  describe '#messaging_permitted?' do
    subject { messaging_permitted?(message) }

    let(:claim) { build :claim, state: }
    let(:message) { build(:message, claim:, claim_action:) }
    let(:claim_action) { nil }

    helper do
      def current_user
        instance_double(User, persona:)
      end
    end

    context 'for case_worker' do
      let(:persona) { create :case_worker }

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
      let(:persona) { create :external_user }

      context 'for a claim with claim actions' do
        let(:state) { 'rejected' }
        let(:claim_action) { 'Request written reasons' }

        it { is_expected.to be_truthy }
      end

      context 'for non redeterminable claim states' do
        let(:claim) { build :claim, state: }

        %w[submitted allocated redetermination awaiting_written_reasons].each do |state|
          context "when claim state is #{state}" do
            let(:state) { state }

            it { is_expected.to be_truthy }
          end
        end
      end

      context 'for redeterminable claim states' do
        let(:claim) { build :claim, state: }

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

    let(:claim) { build(:claim) }
    let(:unused_materials_fee) { create(:misc_fee_type, :miumu) }
    let(:another_fee) { create(:misc_fee_type, :miphc) }
    let(:eligible_fees) { [another_fee] }

    before { allow(claim).to receive(:eligible_misc_fee_types).and_return Array(eligible_fees) }

    context 'with a claim eligible for unused materials fees' do
      let(:eligible_fees) { [unused_materials_fee, another_fee] }

      it { expect(headings[:page_notice]).to eq 'This claim should be eligible for unused materials fees (up to 3 hours)' }

      context 'when unused material fees have already been claimed' do
        before { create(:misc_fee, fee_type: unused_materials_fee, claim:, quantity: 1) }

        it { expect(headings.keys).not_to include(:page_notice) }
      end
    end

    context 'with a claim ineligible for unused materials fees' do
      it { expect(headings.keys).not_to include(:page_notice) }
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

    let(:claim) { build(:claim) }
    let(:unused_materials_fee) { create(:misc_fee_type, :miumu) }
    let(:another_fee) { create(:misc_fee_type, :miphc) }
    let(:eligible_fees) { [another_fee] }

    before { allow(claim).to receive(:eligible_misc_fee_types).and_return Array(eligible_fees) }

    context 'with a claim eligible for unused materials fees' do
      let(:eligible_fees) { [unused_materials_fee, another_fee] }

      it { expect(locals[:unclaimed_fees_notice]).to eq "This claim should be eligible for unused materials fees (up to 3 hours) but they haven't been claimed" }

      context 'when unused material fees have already been claimed' do
        before { create(:misc_fee, fee_type: unused_materials_fee, claim:, quantity: 1) }

        it { expect(locals.keys).not_to include(:unclaimed_fees_notice) }
      end
    end

    context 'with a claim ineligible for unused materials fees' do
      it { expect(locals.keys).not_to include(:unclaimed_fees_notice) }
    end
  end

  describe '#display_unused_materials_notice?' do
    subject { display_unused_materials_notice?(claim) }

    let(:claim) { build(:claim) }
    let(:unused_materials_fee) { create(:misc_fee_type, :miumu) }
    let(:another_fee) { create(:misc_fee_type, :miphc) }
    let(:eligible_fees) { [another_fee] }

    before { allow(claim).to receive(:eligible_misc_fee_types).and_return Array(eligible_fees) }

    context 'with a claim eligible for unused materials fees' do
      let(:eligible_fees) { [unused_materials_fee, another_fee] }

      it { is_expected.to be_truthy }

      context 'when unused material fees have already been claimed' do
        before { create(:misc_fee, fee_type: unused_materials_fee, claim:, quantity: 1) }

        it { is_expected.to be_falsey }
      end
    end

    context 'with a claim ineligible for unused materials fees' do
      it { is_expected.to be_falsey }
    end
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
