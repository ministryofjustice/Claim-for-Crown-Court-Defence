require 'rails_helper'

RSpec.describe Claims::StateTransitionMessageBuilder do
  subject { described_class.new(state, reasons, reason_text).call }

  context '#call' do
   context 'when refused' do
      let(:state) { 'refused' }
      let(:reasons) { %w[wrong_ia duplicate_claim other_refuse] }
      let(:reason_text) { 'refused because...'}

      it 'contains message header' do
        is_expected.to match /Your claim has been refused:/
      end

      it 'contains short description of reason' do
        is_expected.to match /Wrong Instructed Advocate:/
        is_expected.to match /Duplicate claim:/
        is_expected.to match /Other:/
      end

      it 'contains long description of reason' do
        is_expected.to match /.* refused your claim .* different advocate was instructed/
        is_expected.to match /.* refused your claim .* bill has already been paid/
      end

      it 'contains case worker specified other refusal message' do
        is_expected.to match /refused because\.\.\./
      end
    end

    context 'when rejected' do
      let(:state) { 'rejected' }
      let(:reasons) { %w[wrong_maat_ref no_indictment other] }
      let(:reason_text) { 'rejected because...'}

      it 'contains message header' do
        is_expected.to match /Your claim has been rejected:/
      end

      it 'contains short description of reason' do
        is_expected.to match /Wrong MAAT reference:/
        is_expected.to match /No indictment attached:/
        is_expected.to match /Other:/
      end

      it 'contains long description of reason' do
        is_expected.to match /.* rejected your claim .* MAAT reference .* does not match/
        is_expected.to match /.* rejected your claim .* attach the indictment/
      end

      it 'contains case worker specified other rejection message' do
        is_expected.to match /rejected because\.\.\./
      end
    end
  end
end