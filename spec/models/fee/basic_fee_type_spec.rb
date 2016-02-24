require 'rails_helper'

module Fee
  describe BasicFeeType do

    let(:fee_type)  { build :basic_fee_type }
    DATES_ATTENDED_APPLICABLE_FEES = %w( BAF DAF DAH DAJ PCM SAF )
    DATES_ATTENDED_NOT_APPLICABLE_FEES = %w( CAV NDR NOC PPE NPW )

    describe '#has_dates_attended?' do
      context 'for fees that can have dates associated with them' do
        DATES_ATTENDED_APPLICABLE_FEES.each do |code|
          it "#{code} should return true" do
            fee_type.code = code
            expect(fee_type.has_dates_attended?).to be true
          end
        end
      end

      context 'for fees that do not need to have dates associated with them' do
        DATES_ATTENDED_NOT_APPLICABLE_FEES.each do |code|
          it "#{code} should return false" do
            fee_type.code = code
            expect(fee_type.has_dates_attended?).to be false
          end
        end
      end
    end

    describe 'default scope' do
      it 'should order by id' do
        expect(Fee::BasicFeeType.all.to_sql).to include("ORDER BY \"fee_types\".\"id\" ASC")
      end
    end

  end
end
