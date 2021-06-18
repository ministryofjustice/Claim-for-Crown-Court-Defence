require 'rails_helper'

RSpec.describe ErrorPresenter do
  subject(:presenter) { ErrorPresenter.new(claim, filename) }

  let(:claim) { FactoryBot.build :claim }
  let(:filename) { File.dirname(__FILE__) + '/data/error_messages.en.yml' }

  it { is_expected.to delegate_method(:errors_for?).to(:error_details) }
  it { is_expected.to delegate_method(:header_errors).to(:error_details) }
  it { is_expected.to delegate_method(:short_messages_for).to(:error_details) }
  it { is_expected.to delegate_method(:size).to(:error_details) }
  it { expect(presenter.method(:key?)).to eq(presenter.method(:errors_for?)) }
  it { expect(presenter.method(:field_level_error_for)).to eq(presenter.method(:short_messages_for)) }

  describe '#generate_sequence' do
    context 'when fieldname present' do
      it 'returns the value from the error messages file' do
        expect(presenter.send(:generate_sequence, 'name')).to eq 50
      end
    end

    context 'when fieldname not present' do
      it 'returns 99999' do
        expect(presenter.send(:generate_sequence, 'nokey')).to eq 99999
      end
    end
  end

  describe '#header_errors' do
    subject { presenter.header_errors }

    context 'with fieldname and message present in translations' do
      before { claim.errors.add(:date_of_birth, 'too_early') }

      it do
        is_expected.to eq(
          [
            ErrorDetail.new(:date_of_birth, 'The date of birth may not be more than 100 years old', 'Enter a valid date', 'The date of birth is too early', 20)
          ]
        )
      end
    end

    context 'with fieldname but without message present in translations' do
      before { claim.errors.add(:date_of_birth, 'foo_bar') }

      it do
        is_expected.to eq(
          [
            ErrorDetail.new(:date_of_birth, 'Date of birth foo bar', 'Foo bar', 'Date of birth foo bar')
          ]
        )
      end
    end

    context 'without fieldname present in translation file' do
      before { claim.errors.add(:defendant_2_name, 'is invalid') }

      it do
        expect(presenter.header_errors).to eq(
          [
            ErrorDetail.new(:defendant_2_name, 'Defendant 2 name is invalid', 'Is invalid', 'Defendant 2 name is invalid')
          ]
        )
      end
    end

    context 'with nested submodel fieldname and message present in translations' do
      before { claim.errors.add(:defendant_2_first_name, 'blank') }

      it do
        is_expected.to eq(
          [
            ErrorDetail.new(:defendant_2_first_name, 'Enter a first name for the second defendant', 'Enter a name', 'The first name for the second defendant must not be blank')
          ]
        )
      end
    end

    context 'when there are multiple error messages per attribute' do
      before do
        claim.errors.add(:name, 'cannot_be_blank')
        claim.errors.add(:name, 'too_long')
      end

      it do
        is_expected.to eq(
          [
            ErrorDetail.new(:name, 'The claimant name must not be blank, please enter a name', 'Enter a name', 'The claimant name must not be blank', 50),
            ErrorDetail.new(:name, 'The name cannot be longer than 50 characters', 'Too long', 'The name cannot be longer than 50 characters', 50)
          ]
        )
      end
    end
  end

  describe '#field_level_error_for' do
    subject { presenter.field_level_error_for(attribute) }

    context 'with fieldname and message present in translations' do
      before { claim.errors.add(:date_of_birth, 'too_early') }

      let(:attribute) { :date_of_birth }

      it 'returns the short message' do
        is_expected.to eq('Enter a valid date')
      end
    end

    context 'with fieldname but without message present in translations' do
      before { claim.errors.add(:date_of_birth, 'foo_bar') }

      let(:attribute) { :date_of_birth }

      it { is_expected.to eq('Foo bar') }
    end

    context 'without fieldname present in translation file' do
      before { claim.errors.add(:defendant_2_name, 'foo_bar_too') }

      let(:attribute) { :defendant_2_name }

      it { is_expected.to eq('Foo bar too') }
    end
  end
end
