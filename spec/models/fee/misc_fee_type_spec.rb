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

RSpec.describe Fee::MiscFeeType do
  let(:fee_type) { build :misc_fee_type }

  context 'scopes' do
    subject { described_class }

    describe 'default' do
      before do
        create(:misc_fee_type, description: 'Ppppp')
        create(:misc_fee_type, description: 'Xxxxx')
        create(:misc_fee_type, description: 'Sssss')
      end

      it 'orders by description ascending' do
        expect(Fee::MiscFeeType.all.map(&:description)).to eq ['Ppppp','Sssss','Xxxxx']
      end
    end

    it { is_expected.to respond_to(:supplementary) }
    it { is_expected.to respond_to(:without_supplementary_only) }
  end

  describe '#fee_category_name' do
    subject { fee_type.fee_category_name }

    it 'returns the category name' do
      is_expected.to eq 'Miscellaneous Fees'
    end
  end

  describe '#case_uplift?' do
    subject { fee_type.case_uplift? }

    # No Misc fees are case uplifts
    it 'returns false when fee_type is not Case Uplift' do
      fee_type.code = 'MIUPL'
      is_expected.to be_falsey
    end
  end
end
