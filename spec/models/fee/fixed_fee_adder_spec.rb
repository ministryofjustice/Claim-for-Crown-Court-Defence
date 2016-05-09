require 'rails_helper'

module Fee
  describe FixedFeeAdder do

    before(:all) do
      load File.join(Rails.root, 'db', 'seeds', 'case_types.rb')
      load File.join(Rails.root, 'db', 'seeds', 'fee_types.rb')
    end

    after(:all) do
      CaseType.delete_all
      Fee::BaseFeeType.delete_all
    end

    let(:fixed_fee_case_type)  { CaseType.find_by(fee_type_code: 'ACV') }
    let(:grad_fee_case_type)  { CaseType.find_by(fee_type_code: 'GGLTY') }
    let(:fee)   { build :fixed_fee }

    context 'no case type specified' do
      it 'does not add a fixed fee if the claim has no case type' do
        claim = build :claim, case_type: nil
        expect(claim.fixed_fees).to be_empty
        claim.case_type = nil
        claim.save!
        FixedFeeAdder.new(claim).add!
        expect(claim.reload.fixed_fees).to be_empty
      end
      it 'leaves any fixed fees attached to the claim intact'
    end

    context 'case type is not a fixed fee case type' do
      it 'does not add a fixed fee' do
        claim = build :claim, case_type: grad_fee_case_type
        expect(claim.fixed_fees).to be_empty
        claim.save!
        FixedFeeAdder.new(claim).add!
        expect(claim.reload.fixed_fees).to be_empty
      end
    end

    context 'case type is a fixed fee case type' do
      it 'adds the corresponding case type and removes all others' do
        claim = create :claim, case_type: fixed_fee_case_type
        claim.fixed_fees << build(:fixed_fee, fee_type: FixedFeeType.find_by(code: 'CBR'))
        claim.fixed_fees << build(:fixed_fee, fee_type: FixedFeeType.find_by(code: 'CSR'))
        claim.save!
        FixedFeeAdder.new(claim).add!
        claim.reload
        expect(claim.fixed_fees.size).to eq 1
        expect(claim.fixed_fees.first.fee_type.code).to eq 'ACV'

      end
    end

  end
end
