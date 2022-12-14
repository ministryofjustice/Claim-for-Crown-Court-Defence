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
    let(:fee_type) { build(:fixed_fee_type) }

    it_behaves_like 'case upliftable'

    it { should belong_to(:parent) }
    it { should have_many(:children) }

    describe 'default scope' do
      before do
        create(:fixed_fee_type, description: 'Ppppp')
        create(:fixed_fee_type, description: 'Xxxxx')
        create(:fixed_fee_type, description: 'Sssss')
      end

      it 'orders by description ascending' do
        expect(Fee::FixedFeeType.all.pluck(:description)).to eq ['Ppppp', 'Sssss', 'Xxxxx']
      end
    end

    describe '#fee_category_name' do
      it 'returns the category name' do
        expect(fee_type.fee_category_name).to eq 'Fixed Fees'
      end
    end

    describe '#case_uplift?' do
      subject { fee_type.case_uplift? }

      context 'for fixed fees that require additional case numbers' do
        %w[FXACU FXASU FXCBU FXCSU FXCDU FXENU FXNOC].each do |unique_code|
          it "#{unique_code} should return true" do
            expect(fee_type).to receive(:unique_code).at_least(:once).and_return unique_code
            is_expected.to be_truthy
          end
        end
      end

      context 'for fixed fees that do not require additional case numbers' do
        %w[FXACV FXASE FXCBR FXCSE FXCON FXCCD FXENP FXH2S FXSAF FXALT FXASS FXASB].each do |unique_code|
          it "#{unique_code} should return false" do
            expect(fee_type).to receive(:unique_code).at_least(:once).and_return unique_code
            is_expected.to be_falsey
          end
        end
      end
    end
  end
end
