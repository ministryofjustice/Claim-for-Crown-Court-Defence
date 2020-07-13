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

    describe '.agfs_scheme_12s (overidden role scope)' do
      subject { described_class.agfs_scheme_12s.map(&:description) }

      before do
        create(:misc_fee_type, description: 'Scheme 10', roles: %w[agfs agfs_scheme_10] )
        create(:misc_fee_type, description: 'Scheme 12', roles: %w[agfs agfs_scheme_12])
        create(:misc_fee_type, description: 'Scheme 9', roles: %w[agfs agfs_scheme_9])
      end

      it 'returns fee types with agfs scheme 10 OR 12 roles' do
        is_expected.to match_array(['Scheme 10','Scheme 12'])
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
