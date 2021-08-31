# frozen_string_literal: true

RSpec.describe ErrorMessage::Presenter do
  subject(:presenter) { described_class.new(claim, filename) }

  let(:claim) { FactoryBot.build(:claim) }
  let(:filename) { Rails.root.join('spec', 'fixtures', 'config', 'locales', 'en', 'error_messages', 'claim.yml') }

  it { is_expected.to delegate_method(:errors_for?).to(:error_detail_collection) }
  it { is_expected.to delegate_method(:summary_errors).to(:error_detail_collection) }
  it { is_expected.to delegate_method(:short_messages_for).to(:error_detail_collection) }
  it { is_expected.to delegate_method(:formatted_error_messages).to(:error_detail_collection) }
  it { is_expected.to delegate_method(:size).to(:error_detail_collection) }
  it { expect(presenter.method(:key?)).to eq(presenter.method(:errors_for?)) }
  it { expect(presenter.method(:field_errors_for)).to eq(presenter.method(:short_messages_for)) }

  describe '#generate_sequence' do
    context 'when attribute present' do
      it 'returns the value from the error messages file' do
        expect(presenter.send(:generate_sequence, 'name')).to eq 60
      end
    end

    context 'when attribute not present' do
      it 'returns 99999' do
        expect(presenter.send(:generate_sequence, 'nokey')).to eq 99_999
      end
    end
  end

  describe '#summary_errors' do
    subject(:summary_errors) { presenter.summary_errors }

    context 'with attribute and message present in translations' do
      before { claim.errors.add(:date_of_birth, 'too_early') }

      it do
        is_expected.to eq(
          [ErrorMessage::Detail.new(:date_of_birth,
                                    'The date of birth may not be more than 100 years old', 'Enter a valid date',
                                    'The date of birth is too early', 20)]
        )
      end
    end

    context 'with attribute but without message present in translations' do
      before { claim.errors.add(:date_of_birth, 'foo_bar') }

      it do
        is_expected.to eq(
          [
            ErrorMessage::Detail.new(:date_of_birth, 'Date of birth foo bar', 'Foo bar', 'Date of birth foo bar')
          ]
        )
      end
    end

    context 'without attribute present in translation file' do
      before { claim.errors.add(:defendant_2_name, 'is invalid') }

      it do
        is_expected.to eq(
          [
            ErrorMessage::Detail.new(:defendant_2_name, 'Defendant 2 name is invalid', 'Is invalid', 'Defendant 2 name is invalid')
          ]
        )
      end
    end

    context 'with nested submodel attribute and message present in translations' do
      before { claim.errors.add(:defendant_2_first_name, 'blank') }

      it do
        is_expected.to eq(
          [
            ErrorMessage::Detail.new(:defendant_2_first_name, 'Enter a first name for the second defendant', 'Enter a first name', 'The first name for the second defendant must not be blank')
          ]
        )
      end
    end

    context 'with multiple error messages per attribute' do
      before do
        claim.errors.add(:name, 'cannot_be_blank')
        claim.errors.add(:name, 'too_long')
      end

      it do
        is_expected.to eq(
          [ErrorMessage::Detail.new(:name, 'The claimant name must not be blank, please enter a name', 'Enter a name', 'The claimant name must not be blank', 50),
           ErrorMessage::Detail.new(:name, 'The name cannot be longer than 50 characters', 'Too long', 'The name cannot be longer than 50 characters', 50)]
        )
      end
    end

    context 'with multiple errors with and without _seq values from translations' do
      before do
        claim.errors.add(:name, 'cannot_be_blank') # 60
        claim.errors.add(:name, 'too_long') # 60
        claim.errors.add(:defendant_2_first_name, 'blank') # 40 + 10 = 50
        claim.errors.add(:trial_date, 'not_future') # 30
        claim.errors.add(:date_of_birth, 'too_early') # 20
        claim.errors.add(:foo, 'bar') # 99,999
      end

      it { is_expected.to all(be_instance_of(ErrorMessage::Detail)) }
      it { is_expected.to have(6).items }

      it 'sorts the array by sequence values' do
        expect(summary_errors.map(&:sequence)).to eq [20, 30, 50, 60, 60, 99_999]
      end
    end
  end

  describe '#field_errors_for' do
    subject { presenter.field_errors_for(attribute) }

    context 'with no errors for that attribute' do
      let(:attribute) { :date_of_birth }

      it { is_expected.to be_a(String).and be_empty }
    end

    context 'with attribute and message present in translations' do
      before { claim.errors.add(attribute, 'too_early') }

      let(:attribute) { :date_of_birth }

      it { is_expected.to eq('Enter a valid date') }
    end

    context 'with attribute but without message present in translations' do
      before { claim.errors.add(attribute, 'foo_bar') }

      let(:attribute) { :date_of_birth }

      it { is_expected.to eq('Foo bar') }
    end

    context 'with nested error and message present in translations' do
      before do
        claim.errors.add(attribute, 'blank')
      end

      let(:attribute) { :defendant_2_first_name }

      it { is_expected.to eq('Enter a first name') }
    end

    context 'with nested error and message NOT present in translations' do
      before do
        claim.errors.add(attribute, 'foo_bar')
      end

      let(:attribute) { :defendant_2_first_name }

      it { is_expected.to eq('Foo bar') }
    end

    context 'with multiple errors on attribute and message present in translations' do
      before do
        claim.errors.add(:name, 'cannot_be_blank')
        claim.errors.add(:name, 'too_long')
      end

      let(:attribute) { :name }

      it { is_expected.to eq('Enter a name, Too long') }
    end

    context 'with multiple errors on attribute and message NOT present in translations' do
      before do
        claim.errors.add(:name, 'cannot_be_blank')
        claim.errors.add(:name, 'foo_bar')
      end

      let(:attribute) { :name }

      it { is_expected.to eq('Enter a name, Foo bar') }
    end
  end

  # This method is called by govuk-formbuilder to generate summary errors
  # when a presenter instance is injected in to govuk_error_summary.
  #
  describe '#formatted_error_messages' do
    subject(:formatted_error_messages) { presenter.formatted_error_messages }

    context 'with attribute and message present in translations' do
      before { claim.errors.add(:date_of_birth, 'too_early') }

      let(:attribute) { :date_of_birth }

      it { is_expected.to eq([[:date_of_birth, 'The date of birth may not be more than 100 years old']]) }
    end

    context 'with attribute but without message present in translations' do
      before { claim.errors.add(:date_of_birth, 'foo_bar') }

      let(:attribute) { :date_of_birth }

      it { is_expected.to eq([[:date_of_birth, 'Date of birth foo bar']]) }
    end

    context 'without attribute present in translation file' do
      before { claim.errors.add(:defendant_2_name, 'is invalid') }

      let(:attribute) { :defendant_2_name }

      it { is_expected.to eq([[:defendant_2_name, 'Defendant 2 name is invalid']]) }
    end

    context 'with nested submodel attribute and message present in translations' do
      before { claim.errors.add(:defendant_2_first_name, 'blank') }

      let(:attribute) { :defendant_2_first_name }

      it { is_expected.to eq([[:defendant_2_first_name, 'Enter a first name for the second defendant']]) }
    end

    context 'with multiple error messages on separate attributes' do
      before do
        claim.errors.add(:date_of_birth, 'too_early')
        claim.errors.add(:trial_date, 'not_future')
      end

      let(:expected_error_messages) do
        [[:date_of_birth, 'The date of birth may not be more than 100 years old'],
         [:trial_date, 'The trial date may not be in the future']]
      end

      it { is_expected.to eq(expected_error_messages) }
    end

    context 'with multiple error messages on one attribute' do
      before do
        claim.errors.add(:name, 'cannot_be_blank')
        claim.errors.add(:name, 'too_long')
      end

      let(:expected_error_messages) do
        [
          [:name, 'The claimant name must not be blank, please enter a name'],
          [:name, 'The name cannot be longer than 50 characters']
        ]
      end

      it { is_expected.to eq(expected_error_messages) }
    end

    context 'with multiple error messages across attributes' do
      before do
        claim.errors.add(:name, 'cannot_be_blank')
        claim.errors.add(:name, 'too_long')
        claim.errors.add(:defendant_2_first_name, 'blank')
        claim.errors.add(:trial_date, 'not_future')
        claim.errors.add(:date_of_birth, 'too_early')
      end

      let(:expected_error_messages) do
        [
          [:date_of_birth, 'The date of birth may not be more than 100 years old'],
          [:trial_date, 'The trial date may not be in the future'],
          [:defendant_2_first_name, 'Enter a first name for the second defendant'],
          [:name, 'The claimant name must not be blank, please enter a name'],
          [:name, 'The name cannot be longer than 50 characters']
        ]
      end

      it 'sorts the errors by custom _seq value' do
        expect(formatted_error_messages).to eq(expected_error_messages)
      end
    end
  end
end
