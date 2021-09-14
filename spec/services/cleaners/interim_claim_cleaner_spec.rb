require 'rails_helper'
require 'services/cleaners/cleaner_shared_examples'

RSpec.describe Cleaners::InterimClaimCleaner do
  subject(:cleaner) { described_class.new(claim) }

  describe '#call' do
    subject(:call_cleaner) { cleaner.call }

    let(:claim) { create(:interim_claim, disbursements: build_list(:disbursement, 1)) }

    before { claim.fees << build(:interim_fee, fee_type, claim: claim) }

    context 'without a warrant fee' do
      let(:fee_type) { :disbursement }

      it { expect { call_cleaner }.not_to change { claim.disbursements.size }.from(1) }
    end

    context 'with a warrant fee' do
      let(:fee_type) { :warrant }

      it { expect { call_cleaner }.to change { claim.disbursements.size }.from(1).to(0) }
    end
  end
end
