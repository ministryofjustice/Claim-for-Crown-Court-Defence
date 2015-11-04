require 'rails_helper'

describe ErrorPresenter do

  let(:claim)           { FactoryGirl.build :claim }

  let(:filename)        { File.dirname(__FILE__) + '/data/error_messages.en.yml' }
  let(:presenter)       { ErrorPresenter.new(claim, filename) }


  describe 'generate_sequence' do
    context 'base class level fieldnames' do
      context 'fieldname present' do
        it 'should return the value from the error messages file' do
          expect(presenter.send(:generate_sequence, 'name')).to eq 50
        end
      end

      context 'fieldname not present' do
        it 'should return 9999 ' do
          expect(presenter.send(:generate_sequence, 'nokey')).to eq 99999
        end
      end
    end
  end

  context 'one error message per attribute' do
    context 'header_errors' do
      context 'fieldname present in translations file' do

        context 'error string present in translations file' do
          it 'should use the long form of the translation' do
            claim.errors[:name] << 'cannot_be_blank'
            expect(presenter.header_errors).to eq(
              [
                ErrorDetail.new(:name, 'The claimant name must not be blank, please enter a name', 'Enter a name', 10)
              ]
            )
          end
        end

        context 'error string not present in translations file' do
          it 'should generate an error message from the field name and the error' do
            claim.errors[:date_of_birth]  << 'cannot_be_blank'
            expect(presenter.header_errors).to eq(
              [
                ErrorDetail.new(:date_of_birth, 'Date of birth cannot be blank', 'Cannot be blank')
              ]
            )
          end
        end
      end

      context 'fieldname not present in translations file' do
        it 'should generate an error message from the field name and the error' do
          claim.errors[:defendant_2_name] << 'is invalid'
          expect(presenter.header_errors).to eq(
              [
                ErrorDetail.new(:defendant_2_name, 'Defendant 2 name is invalid', 'Is invalid')
              ]
            )
        end
      end
    end


    context '#field_level_error_for' do
      context 'fieldname present in translations file' do

        context 'error string present in translations file' do
          it 'should return the short message' do
            claim.errors[:name] << 'cannot_be_blank'
            expect(presenter.field_level_error_for(:name)).to eq 'Enter a name'
          end
        end

        context 'error string not present in translations file' do
          it 'should return the error message without the fieldame' do
            claim.errors[:date_of_birth]  << 'cannot be blank'
            expect(presenter.field_level_error_for(:date_of_birth)).to eq 'Cannot be blank'
          end
        end
      end

      context 'fieldname not present in translation file' do
        it 'should return the error message without the fieldname' do
          claim.errors[:defendant_2_name] << 'name is invalid'
          expect(presenter.field_level_error_for(:defendant_2_name)).to eq 'Name is invalid'
        end
      end
    end
  end


  context 'multiple error messages per attribute' do

    context 'header messages' do
      context 'fieldname present in translation file' do
        it 'should use the long forms of the translation' do
            claim.errors[:name] << 'cannot_be_blank'
            claim.errors[:name] << 'too_long'
            expect(presenter.header_errors).to eq( 
              [
                ErrorDetail.new(:name, 'The claimant name must not be blank, please enter a name', 'Enter a name'),
                ErrorDetail.new(:name, 'The name cannot be longer than 50 characters', 'Too long')
              ] )
          end
      end
    end
  end

  context 'numbered_submodel_errors' do
    context 'single level numbered submodel errors' do
      it 'should replace the numbered submodel in the title' do
        claim.errors[:defendant_2_first_name]  << 'blank'
        expect(presenter.header_errors).to eq( [
          ErrorDetail.new(:defendant_2_first_name, 'Enter a first name for the second defendant', 'Enter a name')
          ] )
      end
    end
  end

  context 'numbered sub sub model errors' do
    before(:each) do
      claim.errors[:defendant_1_representation_order_1_granting_body] << 'blank'
    end
    it 'should find the error in the tranlations error' do
      expect(presenter.header_errors).to eq( [
        ErrorDetail.new(:defendant_1_representation_order_1_granting_body,
                         'Choose the court that issued the first representation order for the first defendant',
                         'Choose a court') ] )
    end

    it 'should be able to retrieve the field-level error message' do
      expect(presenter.field_level_error_for(:defendant_1_representation_order_1_granting_body)).to eq 'Choose a court'
    end

  end
end


