require 'rails_helper'

describe ExternalUsers::ClaimsHelper do

  describe '#error_class?' do
    let(:presenter) { instance_double(ErrorPresenter) }

    context 'with errors' do
      before do
        allow(presenter).to receive(:field_level_error_for).with(kind_of(Symbol)).and_return('an error')
      end

      it 'should return the default error class if there are any errors in the provided field' do
        returned_class = error_class?(presenter, :test_field)
        expect(returned_class).to eq('field_with_errors')
      end

      it 'should return the specified class if provided' do
        returned_class = error_class?(presenter, :test_field, name: 'custom-error')
        expect(returned_class).to eq('custom-error')
      end
    end

    context 'with errors and multiple fields' do
      before do
        allow(presenter).to receive(:field_level_error_for).with(:test_field_1).and_return(nil)
        allow(presenter).to receive(:field_level_error_for).with(:test_field_2).and_return('an error')
      end

      it 'should return the error class if there are errors in any of the provided field' do
        returned_class = error_class?(presenter, :test_field_1, :test_field_2)
        expect(returned_class).to eq('field_with_errors')
      end

      it 'should return the specified class if provided' do
        returned_class = error_class?(presenter, :test_field_1, :test_field_2, name: 'custom-error')
        expect(returned_class).to eq('custom-error')
      end
    end

    context 'without errors' do
      before do
        allow(presenter).to receive(:field_level_error_for).with(kind_of(Symbol)).and_return(nil)
      end

      it 'should return nil if there are no errors in the provided field' do
        returned_class = error_class?(presenter, :test_field)
        expect(returned_class).to be_nil
      end
    end
  end

end