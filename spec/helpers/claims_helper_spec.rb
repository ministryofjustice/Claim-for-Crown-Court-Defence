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
      allow(claim).to receive(:is_allocated_to_case_worker?).with(case_worker).and_return(true)
      expected_html = '<input checked="checked" id="case_worker_claim_ids_66" name="case_worker[claim_ids][]" type="checkbox" value="66">'
      expect(claim_allocation_checkbox_helper(claim, case_worker)).to eq expected_html
    end

    it 'produces the html for a un-checked checkbox if the claim is not allocated to the case worker' do
      allow(claim).to receive(:is_allocated_to_case_worker?).with(case_worker).and_return(false)
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

    context 'when user has not seen yet the promo' do
      let(:api_promo_seen_setting) { nil }

      it 'returns true' do
        expect(show_api_promo_to_user?).to be_truthy
      end
    end

    context 'when user has seen the promo' do
      let(:api_promo_seen_setting) { '1' }

      it 'returns false' do
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

    context 'when user is a case_worker' do
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

    context 'when user is an external_user' do
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

    context 'with a user with invalid persona' do
      let(:persona) { nil }
      let(:state) { 'submitted' }

      it { is_expected.to be_falsey }
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

    context 'when user is a case_worker' do
      let(:persona) { create :case_worker }

      context 'with a claim with claim actions' do
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

    context 'when user is an external_user' do
      let(:persona) { create :external_user }

      context 'with a claim with claim actions' do
        let(:state) { 'rejected' }
        let(:claim_action) { 'Request written reasons' }

        it { is_expected.to be_truthy }
      end

      context 'with non redeterminable claim states' do
        let(:claim) { build :claim, state: state }

        %w[submitted allocated redetermination awaiting_written_reasons].each do |state|
          context "when claim state is #{state}" do
            let(:state) { state }

            it { is_expected.to be_truthy }
          end
        end
      end

      context 'with redeterminable claim states' do
        let(:claim) { build :claim, state: state }

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
    subject(:headings) { fee_shared_headings(claim, 'test.scope') }

    let(:claim) { build(:claim) }

    context 'with a claim eligible for unused materials fees' do
      before { allow(claim).to receive(:unused_materials_applicable?).and_return true }

      it { expect(headings[:page_notice]).not_to be_nil }

      context 'when unused material fees have already been claimed' do
        before { create(:misc_fee, :miumu_fee, claim: claim, quantity: 1) }

        it { expect(headings.keys).not_to include(:page_notice) }
      end
    end

    context 'with a claim ineligible for unused materials fees' do
      before { allow(claim).to receive(:unused_materials_applicable?).and_return false }

      it { expect(headings.keys).not_to include(:page_notice) }
    end
  end

  describe '#misc_fees_summary_locals' do
    subject(:locals) { misc_fees_summary_locals(claim) }

    let(:claim) { build :claim }

    context 'with a claim eligible for unused materials fees' do
      before { allow(claim).to receive(:unused_materials_applicable?).and_return true }

      it { expect(locals[:unclaimed_fees_notice]).to eq "This claim should be eligible for unused materials fees (up to 3 hours) but they haven't been claimed" }

      context 'when unused material fees have already been claimed' do
        before { create :misc_fee, :miumu_fee, claim: claim, quantity: 1 }

        it { expect(locals.keys).not_to include(:unclaimed_fees_notice) }
      end
    end

    context 'with a claim ineligible for unused materials fees' do
      before { allow(claim).to receive(:unused_materials_applicable?).and_return false }

      it { expect(locals.keys).not_to include(:unclaimed_fees_notice) }
    end
  end
end
