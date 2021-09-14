require 'rails_helper'
require 'services/cleaners/cleaner_shared_examples'

RSpec.describe Cleaners::LitigatorClaimCleaner do
  subject(:cleaner) { described_class.new(claim) }

  describe '#call' do
    subject(:call_cleaner) { cleaner.call }

    context 'when changing a graduated fee claim to a fixed fee claim' do
      let(:claim) do
        create(
          :litigator_claim,
          case_type: build(:case_type, :graduated_fee),
          graduated_fee: build(:graduated_fee)
        )
      end

      before do
        claim.case_type = build(:case_type, :fixed_fee)
        claim.fixed_fee = build(:fixed_fee, :fxase_fee, :with_date_attended, rate: 9.99)
      end

      it { expect { call_cleaner }.not_to change(claim, :fixed_fee).from(an_instance_of(Fee::FixedFee)) }
      it { expect { call_cleaner }.to change(claim, :graduated_fee).from(an_instance_of(Fee::GraduatedFee)).to(nil) }
    end

    context 'when changing a fixed fee claim to a graduated fee claim' do
      let(:claim) do
        create(
          :litigator_claim,
          case_type: build(:case_type, :fixed_fee),
          fixed_fee: build(:fixed_fee, :fxase_fee, :with_date_attended, rate: 9.99)
        )
      end

      before do
        claim.case_type = build(:case_type, :graduated_fee)
        claim.graduated_fee = build(:graduated_fee)
      end

      it { expect { call_cleaner }.to change(claim, :fixed_fee).from(an_instance_of(Fee::FixedFee)).to(nil) }
      it { expect { call_cleaner }.not_to change(claim, :graduated_fee).from(an_instance_of(Fee::GraduatedFee)) }
    end
  end
end
