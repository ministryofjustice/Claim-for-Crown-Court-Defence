# == Schema Information
#
# Table name: fee_types
#
#  id                  :integer          not null, primary key
#  description         :string
#  code                :string
#  created_at          :datetime
#  updated_at          :datetime
#  max_amount          :decimal(, )
#  calculated          :boolean          default(TRUE)
#  type                :string
#  roles               :string
#  parent_id           :integer
#  quantity_is_decimal :boolean          default(FALSE)
#  unique_code         :string
#

require 'rails_helper'

module Fee
  describe InterimFeeType do
    describe '.by_unique_code' do
      it 'returns the record with the matching unique code' do
        create :interim_fee_type, unique_code: 'IFT1'
        create :interim_fee_type, unique_code: 'IFT3'
        ift_2 = create :interim_fee_type, unique_code: 'IFT2'

        expect(described_class.by_unique_code('IFT2')).to eq ift_2
      end
    end

    describe '.by_case_type' do
      subject { described_class.by_case_type(case_type) }

      let!(:trial_start) { create(:interim_fee_type, :trial_start) }
      let!(:retrial_start) { create(:interim_fee_type, :retrial_start) }
      let!(:disbursement_only) { create(:interim_fee_type, :disbursement_only) }

      context 'for trial case types' do
        let(:case_type) { build(:case_type, :trial) }

        it 'returns trial applicable interim fees' do
          is_expected.to match_array [disbursement_only, trial_start]
        end
      end

      context 'for retrial case types' do
        let(:case_type) { build(:case_type, :retrial) }

        it 'returns retrial applicable interim fees' do
          is_expected.to match_array [disbursement_only, retrial_start]
        end
      end
    end
  end
end
