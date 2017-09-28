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
  describe FixedFeeType do

    it { should belong_to(:parent) }
    it { should have_many(:children) }

    let(:fee_type)  { build :fixed_fee_type }

    describe '.top_levels' do
      before(:all) do
        @parent_1 = create :fixed_fee_type
        @parent_2 = create :fixed_fee_type
        @child_1 = create :child_fee_type, description: 'child 1', parent: @parent_1
        @child_2 = create :child_fee_type, description: 'child 2', parent: @parent_2
      end

      after(:all) do
        clean_database
      end

      it 'only returns top level parent fixed fees' do
        expect(Fee::FixedFeeType.top_levels).to match_array([@parent_1, @parent_2])
      end
    end

    describe '#fee_category_name' do
      it 'should return the category name' do
          expect(fee_type.fee_category_name).to eq 'Fixed Fees'
      end
    end

    describe '#case_uplift?' do
      subject { fee_type.case_uplift? }
      it 'returns true for Number of cases uplift' do
        allow(fee_type).to receive(:code).and_return 'NOC'
        is_expected.to be_truthy
      end

      it 'returns false for basic fees not related to case uplifts' do
        allow(fee_type).to receive(:code).and_return 'PPE'
        is_expected.to be_falsey
      end
    end

    describe 'default scope' do
      before do
        create(:fixed_fee_type, description: 'Ppppp')
        create(:fixed_fee_type, description: 'Xxxxx')
        create(:fixed_fee_type, description: 'Sssss')
      end

      it 'should order by description ascending' do
        expect(Fee::FixedFeeType.all.map(&:description)).to eq ['Ppppp','Sssss','Xxxxx']
      end
    end
  end
end
