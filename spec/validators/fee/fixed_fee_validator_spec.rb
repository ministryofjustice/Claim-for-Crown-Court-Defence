require 'rails_helper'

RSpec.describe Fee::FixedFeeValidator, type: :validator do
  include_context 'force-validation'

  let(:fee) { FactoryBot.build :fixed_fee, claim: claim, date: Date.today }
  let(:fee_code) { fee.fee_type.code }

  # AGFS claims are validated as part of the base_fee_validator_spec
  #
  context 'LGFS claim' do
    let(:claim) { FactoryBot.build :litigator_claim }

    before(:each) do
      fee.clear   # reset some attributes set by the factory
      fee.amount = 1.00
    end

    describe '#validate_claim' do
      it { should_error_if_not_present(fee, :claim, 'blank') }
    end

    describe '#validate_fee_type' do
      it { should_error_if_not_present(fee, :fee_type, 'blank') }
    end

    context 'validation of case_type on claim' do
      let(:fixed_fee) { build :fixed_fee, :lgfs }
      let(:grad_fee) { build :graduated_fee }

      context 'claim has a fixed fee case type' do
        let(:claim) { build(:litigator_claim, case_type: build(:case_type, :fixed_fee)) }

        it 'is valid when adding a fixed fee to a claim with a fixed fee case type' do
          fixed_fee.claim = claim
          expect(fixed_fee).to be_valid
        end

        it 'is invalid when adding a graduated fee to a claim with a fixed fee case type' do
          grad_fee.claim = claim
          expect(grad_fee).not_to be_valid
          expect(grad_fee.errors[:claim]).to include('Fixed fee invalid on non-fixed fee case types')
        end
      end

      context 'claim has a graduated fee case type' do
        let(:claim) { build(:litigator_claim, case_type: build(:case_type, :graduated_fee)) }

        it 'is valid when adding a fixed fee to a claim with a fixed fee case type' do
          fixed_fee.claim = claim
          expect(fixed_fee).not_to be_valid
        end

        it 'is invalid when adding a graduated fee to a claim with a fixed fee case type' do
          grad_fee.claim = claim
          expect(grad_fee).to be_valid
        end
      end
    end

    context 'uses the superclass validator' do
      let(:superclass) { described_class.superclass }

      it 'quantity' do
        expect_any_instance_of(superclass).to receive(:validate_quantity)
        fee.valid?
      end

      it 'rate' do
        expect_any_instance_of(superclass).to receive(:validate_rate)
        fee.valid?
      end

      it 'amount' do
        expect_any_instance_of(superclass).to receive(:validate_amount)
        fee.valid?
      end
    end

    describe '#validate_sub_type' do
      let(:fixed_fee_claim) { build :claim, case_type: build(:case_type, :fixed_fee) }
      let!(:non_parent) { create :fixed_fee_type }
      let!(:parent) { create :fixed_fee_type }
      let!(:child) { create :child_fee_type, :asbo, parent: parent }
      let!(:unrelated_child) { create :child_fee_type, :s74 }
      let!(:fee) { build :fixed_fee, :lgfs, fee_type: parent, sub_type: child, claim: fixed_fee_claim, date: nil }

      before(:each) { fee.claim.force_validation = true }

      context 'should error if fee type has children but fee has no sub type' do
        it 'should be present' do
          should_error_if_not_present(fee, :sub_type, 'blank')
        end

        it 'should NOT error if it is a valid sub type' do
          expect(fee).to be_valid
        end

        it 'should error if not a valid sub type' do
          fee.sub_type = unrelated_child
          expect(fee).to_not be_valid
          expect(fee.errors[:sub_type]).to include('invalid')
        end
      end

      it 'should error if fee type has no children but fee has a sub type' do
        fee.fee_type = non_parent
        expect(fee).to_not be_valid
        expect(fee.errors[:sub_type]).to include 'present'
      end
    end

    include_examples 'common LGFS fee date validations'
  end
end
