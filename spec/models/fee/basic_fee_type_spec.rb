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
  describe BasicFeeType do
    let(:fee_type) { build :basic_fee_type }
    DATES_ATTENDED_APPLICABLE_FEES = %w(BAF DAF DAH DAJ PCM SAF DAT)
    DATES_ATTENDED_NOT_APPLICABLE_FEES = %w(CAV NDR NOC PPE NPW)

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

    describe '#case_uplift?' do
      subject { fee_type.case_uplift? }
      context 'for basic fees related to case uplifts' do
        before { allow(fee_type).to receive(:unique_code).and_return 'BANOC' }

        it 'BANOC should return true' do
          is_expected.to be_truthy
        end
      end

      context 'for basic fees not related to case uplifts' do
        %w[BABAF BADAF BADAH BADAJ BASAF BAPCM BACAV BANDR BANPW BAPPE].each do |unique_code|
          before { allow(fee_type).to receive(:unique_code).and_return unique_code }

          it "#{unique_code} should return false" do
            is_expected.to be_falsey
          end
        end
      end
    end

    describe 'default scope' do
      it 'should order by id' do
        expect(Fee::BasicFeeType.all.to_sql).to include('ORDER BY "fee_types"."id" ASC')
      end
    end

    describe 'automatic calculation of amount' do
      context 'for fee types not requiring calculation' do
        let(:fee) { FactoryBot.build :basic_fee, :ppe_fee, quantity: 999, rate: 2.0, amount: 999 }

        it 'should not calculate the amount' do
          expect(fee).to be_valid
          expect(fee.amount).to eq 999
        end
      end
    end
  end
end
