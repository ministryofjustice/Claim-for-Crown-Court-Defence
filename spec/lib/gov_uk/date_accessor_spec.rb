RSpec.describe GovUk::DateAccessor do
  let(:example_class) do
    Class.new do
      include ActiveModel::Model
      include GovUk::DateAccessor
      gov_uk_date_accessor :date_field, :other_date_field
    end
  end

  let(:example_instance) { example_class.new }

  context 'getters' do
    context 'when no date set' do
      subject { example_instance }

      it 'date parts are nil' do
        is_expected.to have_attributes(
                        date_field: nil,
                        date_field_dd: nil,
                        date_field_mm: nil,
                        date_field_yyyy: nil
                      )
      end
    end

    context 'when date set' do
      subject { example_class.new(date_field: date) }
      let(:date) { Date.current }

      it 'date parts are gettable strings' do
        is_expected.to have_attributes(
          date_field: date,
          date_field_dd: date.strftime('%d'),
          date_field_mm: date.strftime('%m'),
          date_field_yyyy: date.strftime('%Y')
        )
      end
    end
  end

  context 'setters' do
    subject { example_instance }

    context 'date parts' do
      context 'when all set' do
        it 'date field is set' do
          example_instance.date_field_dd = '01'
          example_instance.date_field_mm = '01'
          example_instance.date_field_yyyy = '2019'
          expect(example_instance.date_field).to eql(Date.new(2019, 01, 01))
        end
      end

      context 'when only day set' do
        it 'date field set to nil' do
          example_instance.date_field_dd = '01'
          expect(example_instance.date_field).to be_nil
        end
      end

      context 'when only month set' do
        it 'date field set to nil' do
          example_instance.date_field_mm = '01'
          expect(example_instance.date_field).to be_nil
        end
      end

      context 'when only year set' do
        it 'date field set to nil' do
          example_instance.date_field_yyyy = '2019'
          expect(example_instance.date_field).to be_nil
        end
      end

      context 'when only day and month set' do
        it 'date field set to nil' do
          example_instance.date_field_dd = '01'
          example_instance.date_field_mm = '01'
          expect(example_instance.date_field).to be_nil
        end
      end

      context 'when invalid year set more than 50 years ago' do
        it 'date field set to nil' do
          example_instance.date_field_dd = '01'
          example_instance.date_field_mm = '01'
          example_instance.date_field_yyyy = Date.current.year - 51
          expect(example_instance.date_field).to be_nil
        end
      end

      context 'when year set more than 50 years in future' do
        it 'date field set to nil' do
          example_instance.date_field_dd = '01'
          example_instance.date_field_mm = '01'
          example_instance.date_field_yyyy = Date.current.year + 51
          expect(example_instance.date_field).to be_nil
        end
      end
    end

    context 'date' do
      let(:date) { Date.new(2019, 02, 12) }

      it 'sets date part fields' do
        example_instance.date_field = date

        is_expected.to have_attributes(
          date_field: date,
          date_field_dd: date.strftime('%d'),
          date_field_mm: date.strftime('%m'),
          date_field_yyyy: date.strftime('%Y')
        )
      end
    end
  end
end
