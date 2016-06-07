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
#

require 'rails_helper'

module Fee
  describe BasicFeeType do

    let(:fee_type) { build :basic_fee_type }
    DATES_ATTENDED_APPLICABLE_FEES = %w( BAF DAF DAH DAJ PCM SAF ).freeze
    DATES_ATTENDED_NOT_APPLICABLE_FEES = %w( CAV NDR NOC PPE NPW ).freeze

    describe '#requires_dates_attended?' do
      context 'for fees that can have dates associated with them' do
        DATES_ATTENDED_APPLICABLE_FEES.each do |code|
          it "#{code} should return true" do
            fee_type.code = code
            expect(fee_type.requires_dates_attended?).to be true
          end
        end
      end

      context 'for fees that do not need to have dates associated with them' do
        DATES_ATTENDED_NOT_APPLICABLE_FEES.each do |code|
          it "#{code} should return false" do
            fee_type.code = code
            expect(fee_type.requires_dates_attended?).to be false
          end
        end
      end
    end

    describe 'default scope' do
      it 'should order by id' do
        expect(Fee::BasicFeeType.all.to_sql).to include("ORDER BY \"fee_types\".\"id\" ASC")
      end
    end

    describe 'automatic calculation of amount' do
      context 'for fee types not requiring calculation' do
        let(:fee) { FactoryGirl.build :basic_fee, :ppe_fee, quantity: 999, rate: 2.0, amount: 999 }

        it 'should not calculate the amount' do
          expect(fee).to be_valid
          expect(fee.amount).to eq 999
        end
      end
    end
  end
end
