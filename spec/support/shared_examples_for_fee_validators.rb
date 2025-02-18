# TODO: to be reviewied after migrations are complete
# and remove examples using "snake cased" error messages
# as the govuk formbuilder expects the user friendly error messages
#

RSpec.shared_examples 'common LGFS fee date validations' do
  describe '#validate_date' do
    it { should_error_if_not_present(fee, :date, 'Enter the (.*?)(fixed|graduated) fee date') }

    it 'adds error if too far in the past' do
      fee.date = 11.years.ago
      expect(fee).to_not be_valid
      expect(fee.errors[:date]).to include(match(/(.*?)(Fixed|Graduated) fee date cannot be too far in the past/))
    end

    it 'adds error if in the future' do
      fee.date = 3.days.from_now
      expect(fee).not_to be_valid
      expect(fee.errors[:date]).to include(match(/(.*?)(Fixed|Graduated) fee date cannot be too far in the future/))
    end

    it 'adds error if before the first repo order date' do
      allow(claim).to receive(:earliest_representation_order_date).and_return(Time.zone.today)
      allow(fee).to receive(:claim).and_return(claim)

      fee.date = Time.zone.today - 3.days
      expect(fee).not_to be_valid
      expect(fee.errors[:date]).to include(match(/.* date cannot be no earlier than two years before .*/))
    end
  end
end

RSpec.shared_examples 'common LGFS amount validations' do
  describe '#validate_amount' do
    let(:amount_error_message) do
      'Enter a valid amount for the (.*?)(graduated|hardship|interim|miscellaneous|transfer|warrant) fee'
    end

    let(:amount_max_limit_error_message) do
      'The amount for the (.*?)(graduated|hardship|interim|miscellaneous|transfer|warrant) fee exceeds the limit'
    end

    it 'adds error if amount is blank' do
      should_error_if_equal_to_value(fee, :amount, '', amount_error_message)
    end

    it 'adds error if amount is equal to zero' do
      should_error_if_equal_to_value(fee, :amount, 0.00, amount_error_message)
    end

    it 'adds error if amount is less than zero' do
      should_error_if_equal_to_value(fee, :amount, -10.00, amount_error_message)
    end

    it 'adds error if amount is greater than the max limit' do
      should_error_if_equal_to_value(fee, :amount, 200_001, amount_max_limit_error_message)
    end
  end
end

RSpec.shared_examples 'common AGFS number of cases uplift validations' do
  let(:noc_case_number_mismatch_error_message) do
    'The number of case uplifts does not match the additional case numbers'
  end
  let(:noc_case_number_invalid_error_message) do
    'Enter valid case numbers for the Number of cases uplift'
  end
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
      should_error_with(noc_fee, :case_numbers, 'Enter case numbers for the Number of cases uplift')
    end

    it 'when case_numbers is not blank and quantity is 0' do
      noc_fee.quantity = 0
      noc_fee.case_numbers = 'A20161234'
      should_error_with(noc_fee, :case_numbers, noc_case_number_mismatch_error_message)
    end

    it 'when quantity and number of additional cases do not match' do
      noc_fee.case_numbers = 'A20161234 , A20148888'
      should_error_with(noc_fee, :case_numbers, noc_case_number_mismatch_error_message)
    end

    it 'when case number is equal to main case number' do
      noc_fee.case_numbers = claim.case_number
      should_error_with(noc_fee, :case_numbers, 'The additional case number must be different to the main case number')
    end

    it 'when a single invalid format of case number entered' do
      should_error_if_equal_to_value(noc_fee, :case_numbers, 'G20208765', noc_case_number_invalid_error_message)
    end

    it 'when a single invalid format of URN entered' do
      should_error_if_equal_to_value(noc_fee, :case_numbers, '12 3', noc_case_number_invalid_error_message)
    end

    it 'when any case number is of invalid format' do
      noc_fee.case_numbers = 'A20161234,Z123*,A20148888'
      should_error_with(noc_fee, :case_numbers, noc_case_number_invalid_error_message)
    end

    it 'when any URN is of invalid format' do
      noc_fee.case_numbers = 'ABCDEFGHIJ,Z123*,1234567890'
      should_error_with(noc_fee, :case_numbers, noc_case_number_invalid_error_message)
    end
  end

  context 'when there is more than one case uplift' do
    before do
      noc_fee.quantity = 2
    end

    context 'case number list formatting' do
      context 'valid' do
        it 'when comma separated' do
          noc_fee.case_numbers = 'A20161234,A20148888'
          should_not_error(noc_fee, :case_numbers)
        end

        it 'when commas and whitespace separated' do
          noc_fee.case_numbers = 'A20161234 , A20148888'
          should_not_error(noc_fee, :case_numbers)
        end
      end

      context 'invalid' do
        it 'when other delimiters used' do
          noc_fee.case_numbers = 'A20161234;A20148888'
          should_error_with(noc_fee, :case_numbers, noc_case_number_invalid_error_message)
        end
      end
    end

    it 'adds error if number of cases provided does not match the quantity claimed' do
      noc_fee.case_numbers = 'A20161234'
      should_error_with(noc_fee, :case_numbers, noc_case_number_mismatch_error_message)
    end
  end
end

RSpec.shared_examples 'common warrant fee validations' do
  describe '#validate_warrant_issued_date' do
    it 'is invalid if present and too far in the past' do
      fee.warrant_issued_date = 11.years.ago
      expect(fee).not_to be_valid
      expect(fee.errors[:warrant_issued_date]).to include 'Warrant issued date cannot be too far in the past'
    end

    it 'is invalid if present and in the future' do
      fee.warrant_issued_date = 3.days.from_now
      expect(fee).not_to be_valid
      expect(fee.errors[:warrant_issued_date]).to include 'Warrant issued date cannot be too far in the future'
    end

    it 'is invalid if not present' do
      fee.warrant_issued_date = nil
      expect(fee).not_to be_valid
      expect(fee.errors[:warrant_issued_date]).to eq(['Enter a warrant issued date'])
    end
  end

  describe '#validate_warrant_executed_date' do
    it 'raises error if before warrant_issued_date' do
      fee.warrant_executed_date = fee.warrant_issued_date - 1.day
      expect(fee).not_to be_valid
      expect(fee.errors[:warrant_executed_date]).to eq(['The warrant executed date is before the issued date'])
    end

    it 'raises error if in future' do
      fee.warrant_executed_date = 3.days.from_now
      expect(fee).not_to be_valid
      expect(fee.errors[:warrant_executed_date]).to include 'Warrant executed date cannot be too far in the future'
    end

    it 'does not raise error if absent' do
      fee.warrant_executed_date = nil
      expect(fee).to be_valid
    end

    it 'does not raise error if present and in the past' do
      fee.warrant_executed_date = 1.day.ago
      expect(fee).to be_valid
    end
  end
end
