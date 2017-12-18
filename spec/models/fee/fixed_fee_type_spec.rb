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
require_relative 'shared_examples_for_case_uplifts'

module Fee
  describe FixedFeeType do
    let(:fee_type) { build :fixed_fee_type }
    it_behaves_like 'case upliftable'

    it { should belong_to(:parent) }
    it { should have_many(:children) }

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

    describe 'default scope' do
      before do
        create(:fixed_fee_type, description: 'Ppppp')
        create(:fixed_fee_type, description: 'Xxxxx')
        create(:fixed_fee_type, description: 'Sssss')
      end

      it 'should order by description ascending' do
        expect(Fee::FixedFeeType.all.pluck(:description)).to eq ['Ppppp','Sssss','Xxxxx']
      end
    end

    describe '#fee_category_name' do
      it 'should return the category name' do
          expect(fee_type.fee_category_name).to eq 'Fixed Fees'
      end
    end

    describe '#case_uplift?' do
      subject { fee_type.case_uplift? }

      context 'for fixed fees that require additional case numbers' do
        %w[FXACU FXASU FXCBU FXCSU FXCDU FXENU FXNOC].each do |unique_code|
          before { allow(fee_type).to receive(:unique_code).and_return unique_code }

          it "#{unique_code} should return true" do
            is_expected.to be_truthy
          end
        end
      end

      context 'for fixed fees that do not require additional case numbers' do
        %w[FXACV FXASE FXCBR FXCSE FXCON FXCCD FXENP FXH2S FXSAF FXALT FXASS FXASB].each do |unique_code|
          before { allow(fee_type).to receive(:code).and_return unique_code }

          it "#{unique_code} should return false" do
            is_expected.to be_falsey
          end
        end
      end
    end
  end
end
