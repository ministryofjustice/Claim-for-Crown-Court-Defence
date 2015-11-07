require 'rails_helper'

describe ErrorResponse do

    VALID_MODEL_KLASSES = [::Fee, ::Expense, ::Claim, ::Defendant, ::DateAttended, ::RepresentationOrder]

    let(:claim) { FactoryGirl.build :claim, case_number: 'A123456' }
    let(:er) { ErrorResponse.new(claim)}

    before(:each) do
      claim.force_validation = true
      claim.valid?
    end

    context 'accepts only known model objects' do
      skip '- SKIPPED as need a way to test acceptable model objects' do
        VALID_MODEL_KLASSES.each do |model_klass|
          it "accepts #{model_klass}" do
            model_instance = FactoryGirl.build(model_klass.to_s.downcase.to_sym)
            expect { er = ErrorResponse.new(model_instance) }.to raise_error
            expect(er.model).not_to be_nil
          end
        end
      end
    end

    it 'returns status and body' do
      expect(er).to respond_to :status
      expect(er).to respond_to :body
    end

    it 'returned body is in JSON format' do
      expect{ er.body.to_json }.not_to raise_error
    end

    it 'raises an error if model is valid' do
      claim.update_attribute(:case_number, 'A12345678')
      claim.valid?
      expect{ ErrorResponse.new(claim) }.to raise_error("unable to build error response as no errors were found")
    end

end
