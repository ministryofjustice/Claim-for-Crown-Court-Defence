require 'rails_helper'

describe ErrorPresenter do
  let(:claim)           { FactoryBot.build :claim }

  let(:filename)        { File.dirname(__FILE__) + '/data/error_messages.en.yml' }
  let(:presenter)       { ErrorPresenter.new(claim, filename) }

  describe 'generate_sequence' do
    context 'base class level fieldnames' do
      context 'fieldname present' do
        it 'returns the value from the error messages file' do
          expect(presenter.send(:generate_sequence, 'name')).to eq 50
        end
      end

      context 'fieldname not present' do
        it 'returns 99999' do
          expect(presenter.send(:generate_sequence, 'nokey')).to eq 99999
        end
      end
    end
  end

  context 'one error message per attribute' do
    context 'header_errors' do
      context 'fieldname present in translations file' do
        context 'error string present in translations file' do
          it 'uses the long form of the translation' do
            claim.errors.add(:name, 'cannot_be_blank')
            expect(presenter.header_errors).to eq(
              [
                ErrorDetail.new(:name, 'The claimant name must not be blank, please enter a name', 'Enter a name', 'The claimant name must not be blank', 10)
              ]
            )
          end
        end

        context 'error string not present in translations file' do
          it 'generates an error message from the field name and the error' do
            claim.errors.add(:date_of_birth, 'cannot_be_blank')
            expect(presenter.header_errors).to eq(
              [
                ErrorDetail.new(:date_of_birth, 'Date of birth cannot be blank', 'Cannot be blank', 'Date of birth cannot be blank')
              ]
            )
          end
        end
      end

      context 'fieldname not present in translations file' do
        it 'generates an error message from the field name and the error' do
          claim.errors.add(:defendant_2_name, 'is invalid')
          expect(presenter.header_errors).to eq(
            [
              ErrorDetail.new(:defendant_2_name, 'Defendant 2 name is invalid', 'Is invalid', 'Defendant 2 name is invalid')
            ]
          )
        end
      end
    end

    context '#field_level_error_for' do
      context 'fieldname present in translations file' do
        context 'error string present in translations file' do
          it 'returns the short message' do
            claim.errors.add(:name, 'cannot_be_blank')
            expect(presenter.field_level_error_for(:name)).to eq 'Enter a name'
          end
        end

        context 'error string not present in translations file' do
          it 'returns the error message without the fieldame' do
            claim.errors.add(:date_of_birth, 'cannot be blank')
            expect(presenter.field_level_error_for(:date_of_birth)).to eq 'Cannot be blank'
          end
        end
      end

      context 'fieldname not present in translation file' do
        it 'returns the error message without the fieldname' do
          claim.errors.add(:defendant_2_name, 'name is invalid')
          expect(presenter.field_level_error_for(:defendant_2_name)).to eq 'Name is invalid'
        end
      end
    end
  end

  context 'multiple error messages per attribute' do
    context 'header messages' do
      context 'fieldname present in translation file' do
        it 'uses the long forms of the translation' do
          claim.errors.add(:name,'cannot_be_blank')
          claim.errors.add(:name,'too_long')
          expect(presenter.header_errors).to eq(
            [
              ErrorDetail.new(:name, 'The claimant name must not be blank, please enter a name', 'Enter a name', 'The claimant name must not be blank', 50),
              ErrorDetail.new(:name, 'The name cannot be longer than 50 characters', 'Too long', 'The name cannot be longer than 50 characters', 50)
            ]
          )
        end
      end
    end
  end

  context 'numbered_submodel_errors' do
    context 'single level numbered submodel errors' do
      it 'replaces the numbered submodel in the title' do
        claim.errors.add(:defendant_2_first_name, 'blank')
        expect(presenter.header_errors).to eq(
          [
            ErrorDetail.new(:defendant_2_first_name, 'Enter a first name for the second defendant', 'Enter a name', 'The first name for the second defendant must not be blank')
          ]
        )
      end
    end
  end
end
