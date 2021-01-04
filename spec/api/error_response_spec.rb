require 'rails_helper'

describe API::ErrorResponse do
    VALID_MODEL_KLASSES = [::Fee, ::Expense, ::Disbursement, ::Claim, ::Defendant, ::DateAttended, ::RepresentationOrder]
    EXCEPTION_KLASSES = [RuntimeError, ArgumentError]

    let(:claim) { FactoryBot.build :claim, case_number: 'A123456' }
    let(:er) { described_class.new(claim) }

    before(:each) do
      claim.force_validation = true
      claim.valid?
    end

    context 'accepts specific model objects' do
      VALID_MODEL_KLASSES.each do |model_klass|
        let(:model_instance) { FactoryBot.build(model_klass.name.underscore.to_sym) }
        it "accepts #{model_klass.name}" do
          expect { er = described_class.new(model_instance) }.to raise_error(RuntimeError ,'unable to build error response as no errors were found')
        end
      end
    end

    context 'accepts exception objects' do
      EXCEPTION_KLASSES.each do |exception_klass|
        let(:ex) { exception_klass.new('my exception message') }

        it "does not raise a runtime error for #{exception_klass}" do
          expect { er = described_class.new(ex) }.not_to raise_error
        end

        it 'populates status with 400 and body with a JSON error format message' do
          er = described_class.new(ex)
          expect(er.status).to eql 400
          json = JSON.parse(er.body.to_json)
          expect(json[0]['error']).to include('my exception message')
        end
      end

      it 'populates status with 401 if exception message is "Unauthorized"' do
        ex = ArgumentError.new('Unauthorised')
        er = described_class.new(ex)
        expect(er.status).to eql 401
      end
    end

    context 'accepts other objects without breaking' do
      [1,'1',[1,2]].each do |other_object|
        it "accepts #{other_object.class.name} without raising an error" do
          expect { described_class.new(other_object) }.not_to raise_error
        end

        it 'populates statuswith 400 and body with general error message' do
          er = described_class.new(other_object)
          expect(er.status).to eq 400
          json = JSON.parse(er.body.to_json)
          expect(json[0]['error']).to include("No message provided by object #{other_object.class.name}")
        end
      end
    end

    it 'returns status and body' do
      expect(er).to respond_to :status
      expect(er).to respond_to :body
    end

    it 'returned body is in JSON format' do
      expect { er.body.to_json }.not_to raise_error
    end

    it 'raises an error if model is valid' do  #pending because claim.errors contains an empty array for external_users
      claim.update_attribute(:case_number, 'A20161234')
      expect(claim).to be_valid
      expect { described_class.new(claim) }.to raise_error('unable to build error response as no errors were found')
    end
end
