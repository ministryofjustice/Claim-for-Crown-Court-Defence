RSpec.shared_examples 'common LGFS fee date validations' do
  describe '#validate_date' do
    it { should_error_if_not_present(fee, :date, 'blank') }

    it 'adds error if too far in the past' do
      fee.date = 11.years.ago
      expect(fee).to_not be_valid
      expect(fee.errors[:date]).to include 'check_not_too_far_in_past'
    end

    it 'adds error if in the future' do
      fee.date = 3.days.from_now
      expect(fee).not_to be_valid
      expect(fee.errors[:date]).to include 'check_not_in_future'
    end

    it 'adds error if before the first repo order date' do
      allow(claim).to receive(:earliest_representation_order_date).and_return(Date.today)
      allow(fee).to receive(:claim).and_return(claim)

      fee.date = Date.today - 3.days
      expect(fee).not_to be_valid
      expect(fee.errors[:date]).to include 'too_long_before_earliest_reporder'
    end
  end
end

RSpec.shared_examples 'common LGFS amount validations' do
  describe '#validate_amount' do
    it 'adds error if amount is blank' do
      should_error_if_equal_to_value(fee, :amount, '', 'numericality')
    end

    it 'adds error if amount is equal to zero' do
      should_error_if_equal_to_value(fee, :amount, 0.00, 'numericality')
    end

    it 'adds error if amount is less than zero' do
      should_error_if_equal_to_value(fee, :amount, -10.00, 'numericality')
    end

    it 'adds error if amount is greater than the max limit' do
      should_error_if_equal_to_value(fee, :amount, 200_001, 'item_max_amount')
    end
  end
end

RSpec.shared_examples 'common AGFS number of cases uplift validations' do
  context 'case numbers list valid' do
    it 'when case_numbers is blank and quantity is zero' do
      noc_fee.quantity = 0
      noc_fee.rate = 0
      noc_fee.case_numbers = ''
      should_not_error(noc_fee, :case_numbers)
    end

    context 'when submitted by API' do
      before do
        noc_fee.claim.source = 'api'
      end

      it 'when case_numbers is blank and quantity is not zero' do
        noc_fee.quantity = 1
        should_not_error(noc_fee, :case_numbers)
      end

      it 'when single valid format of case number entered' do
        noc_fee.case_numbers = 'A20161234'
        should_not_error(noc_fee, :case_numbers)
      end

      it 'when single valid format of URN entered' do
        noc_fee.case_numbers = '1234567890AAAAAAAAAA'
        should_not_error(noc_fee, :case_numbers)
      end

      it 'when quantity and number of additional cases match' do
        noc_fee.quantity = 2
        noc_fee.case_numbers = 'A20161234,1234567890AAAAAAAAAA'
        should_not_error(noc_fee, :case_numbers)
      end
    end
  end

  context 'case numbers list invalid' do
    it 'when case_numbers is blank and quantity is not zero' do
      noc_fee.quantity = 1
      noc_fee.case_numbers = ''
      should_error_with(noc_fee, :case_numbers, 'blank')
    end

    it 'when case_numbers is not blank and quantity is 0' do
      noc_fee.quantity = 0
      noc_fee.case_numbers = 'A20161234'
      should_error_with(noc_fee, :case_numbers, 'noc_qty_mismatch')
    end

    it 'when quantity and number of additional cases do not match' do
      noc_fee.case_numbers = 'A20161234 , A20158888'
      should_error_with(noc_fee, :case_numbers, 'noc_qty_mismatch')
    end

    it 'when case number is equal to main case number' do
      noc_fee.case_numbers = claim.case_number
      should_error_with(noc_fee, :case_numbers, 'eqls_claim_case_number')
    end

    it 'when a single invalid format of case number entered' do
      should_error_if_equal_to_value(noc_fee, :case_numbers, 'G20208765', 'invalid')
    end

    it 'when a single invalid format of URN entered' do
      should_error_if_equal_to_value(noc_fee, :case_numbers, '12 3', 'invalid')
    end

    it 'when any case number is of invalid format' do
      noc_fee.case_numbers = 'A20161234,Z123*,A20158888'
      should_error_with(noc_fee, :case_numbers, 'invalid')
    end

    it 'when any URN is of invalid format' do
      noc_fee.case_numbers = 'ABCDEFGHIJ,Z123*,1234567890'
      should_error_with(noc_fee, :case_numbers, 'invalid')
    end
  end

  context 'when there is more than one case uplift' do
    before do
      noc_fee.quantity = 2
    end

    context 'case number list formatting' do
      context 'valid' do
        it 'when comma separated' do
          noc_fee.case_numbers = 'A20161234,A20158888'
          should_not_error(noc_fee, :case_numbers)
        end

        it 'when commas and whitespace separated' do
          noc_fee.case_numbers = 'A20161234 , A20158888'
          should_not_error(noc_fee, :case_numbers)
        end
      end

      context 'invalid' do
        it 'when other delimiters used' do
          noc_fee.case_numbers = 'A20161234;A20158888'
          should_error_with(noc_fee, :case_numbers, 'invalid')
        end
      end
    end

    it 'adds error if number of cases provided does not match the quantity claimed' do
      noc_fee.case_numbers = 'A20161234'
      should_error_with(noc_fee, :case_numbers, 'noc_qty_mismatch')
    end
  end
end

RSpec.shared_examples 'common warrant fee validations' do
  describe '#validate_warrant_issued_date' do
    it 'should be invalid if present and too far in the past' do
      fee.warrant_issued_date = 11.years.ago
      expect(fee).to be_invalid
      expect(fee.errors[:warrant_issued_date]).to include 'check_not_too_far_in_past'
    end

    it 'should be invalid if present and in the future' do
      fee.warrant_issued_date = 3.days.from_now
      expect(fee).to be_invalid
      expect(fee.errors[:warrant_issued_date]).to include 'check_not_in_future'
    end

    it 'should be invalid if not present' do
      fee.warrant_issued_date = nil
      expect(fee).to be_invalid
      expect(fee.errors[:warrant_issued_date]).to eq(['blank'])
    end
  end

  describe '#validate_warrant_executed_date' do
    it 'should raise error if before warrant_issued_date' do
      fee.warrant_executed_date = fee.warrant_issued_date - 1.day
      expect(fee).to be_invalid
      expect(fee.errors[:warrant_executed_date]).to eq(['warrant_executed_before_issued'])
    end

    it 'should raise error if in future' do
      fee.warrant_executed_date = 3.days.from_now
      expect(fee).to be_invalid
      expect(fee.errors[:warrant_executed_date]).to include 'check_not_in_future'
    end

    it 'should not raise error if absent' do
      fee.warrant_executed_date = nil
      expect(fee).to be_valid
    end

    it 'should not raise error if present and in the past' do
      fee.warrant_executed_date = 1.day.ago
      expect(fee).to be_valid
    end
  end
end
