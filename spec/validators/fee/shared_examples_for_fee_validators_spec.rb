shared_examples 'common fee date validations' do

  describe '#validate_date' do
    it { should_error_if_not_present(fee, :date, 'blank') }

    it 'should be invalid if too far in the past' do
      fee.date = 11.years.ago
      expect(fee).to_not be_valid
      expect(fee.errors[:date]).to include 'check_not_too_far_in_past'
    end

    it 'should be invalid if in the future' do
      fee.date = 3.days.from_now
      expect(fee).not_to be_valid
      expect(fee.errors[:date]).to include 'check_not_in_future'
    end

    it 'should be invalid if before the first repo order date' do
      allow(claim).to receive(:earliest_representation_order).and_return(instance_double(RepresentationOrder, representation_order_date: Date.today))
      allow(fee).to receive(:claim).and_return(claim)

      fee.date = Date.today - 3.days
      expect(fee).not_to be_valid
      expect(fee.errors[:date]).to include 'too_long_before_earliest_reporder'
    end
  end
end

shared_examples 'common amount validations' do
  describe '#validate_amount' do
    it 'should error if amount is blank' do
      should_error_if_equal_to_value(fee, :amount, '', 'numericality')
    end

    it 'should error if amount is equal to zero' do
      should_error_if_equal_to_value(fee, :amount, 0.00, 'numericality')
    end

    it 'should error if amount is less than zero' do
      should_error_if_equal_to_value(fee, :amount, -10.00, 'numericality')
    end

    it 'should error if amount is greater than the max limit' do
      should_error_if_equal_to_value(fee, :amount, 200_001, 'item_max_amount')
    end
  end
end
