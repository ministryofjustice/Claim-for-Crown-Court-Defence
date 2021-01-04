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

  context 'when querying using scopes' do
    it { expect(described_class).to respond_to(:supplementary, :without_supplementary_only, :agfs_scheme_12s) }

    describe '.all (default scope)' do
      subject { described_class.all.map(&:description) }

      before do
        create(:misc_fee_type, description: 'A')
        create(:misc_fee_type, description: 'C')
        create(:misc_fee_type, description: 'B')
      end

      it 'orders by description ascending' do
       is_expected.to eq ['A','B','C']
      end
    end

    describe '.supplementary' do
      subject { described_class.supplementary.map(&:unique_code) }

      before do
        create(:misc_fee_type, unique_code: 'NOT_SUPPLEMENTARY')
        create(:misc_fee_type, unique_code: 'MISAF')
        create(:misc_fee_type, unique_code: 'MISAU')
      end

      it 'returns fee types with unique codes defined in class constants' do
        is_expected.to match_array(%w[MISAF MISAU])
      end
    end

    describe '.without_supplementary_only' do
      subject { described_class.without_supplementary_only.map(&:unique_code) }

      before do
        create(:misc_fee_type, unique_code: 'MISAF')
        create(:misc_fee_type, unique_code: 'MISAU')
      end

      it 'returns fee types excluding those for only supplementary claims' do
        is_expected.to match_array(%w[MISAU])
      end
    end

    describe '.without_trial_fee_only' do
      subject { described_class.without_trial_fee_only.map(&:unique_code) }

      before do
        create(:misc_fee_type, unique_code: 'MISPF')
        create(:misc_fee_type, unique_code: 'MIUMU')
        create(:misc_fee_type, unique_code: 'MIUMO')
      end

      it 'returns fee types excluding those only for "trial" case type claims' do
        is_expected.to match_array(%w[MISPF])
      end
    end
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
