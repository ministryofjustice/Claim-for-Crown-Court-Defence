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
      allow(claim).to receive(:earliest_representation_order_date).and_return(Date.today)
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

shared_examples 'common AGFS number of cases uplift validations' do
  # TODO: require presence once impact on API consumers can be mitigated by comms with vendors
  it 'should NOT error if case_numbers is blank (for now)' do
    should_not_error(noc_fee, :case_numbers)
  end

  it 'should error if single case number is invalid' do
    should_error_if_equal_to_value(noc_fee, :case_numbers, '123', 'invalid')
  end

  it 'should be valid for a single valid format of case number' do
    noc_fee.case_numbers = 'A20161234'
    should_not_error(noc_fee, :case_numbers)
  end

  it 'should error if any case number is invalid' do
    noc_fee.case_numbers = 'A20161234,Z123,A20158888'
    should_error_with(noc_fee, :case_numbers, 'invalid')
  end

  it 'should error if quantity and number of additional cases do not match' do
    noc_fee.case_numbers = 'A20161234 , A20158888'
    should_error_with(noc_fee, :case_numbers, 'noc_qty_mismatch')
  end

  context 'with more than one case uplift' do
    before do
      noc_fee.quantity = 2
    end

    it 'should be valid for several case numbers' do
      noc_fee.case_numbers = 'A20161234,A20158888'
      should_not_error(noc_fee, :case_numbers)
    end

    it 'should be valid for several case numbers with spaces between them' do
      noc_fee.case_numbers = 'A20161234 , A20158888'
      should_not_error(noc_fee, :case_numbers)
    end

    it 'should error if number of cases provided does not match the quantity claimed' do
      noc_fee.case_numbers = 'A20161234'
      should_error_with(noc_fee, :case_numbers, 'noc_qty_mismatch')
    end
  end
end
