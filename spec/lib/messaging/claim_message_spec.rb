require 'rails_helper'

describe Messaging::ClaimMessage do
  let(:claim) { create(:authorised_claim) }

  subject { described_class.new(claim) }

  it 'should have a payload' do
    expect(subject.payload).to match(/<cbo:claim_uuid>#{claim.uuid}<\/cbo:claim_uuid>/)
  end

  describe 'publishing claims' do
    context 'when message is not valid' do
      before(:each) do
        allow(subject).to receive(:valid_message?).and_return(false)
      end

      it 'should raise an exception' do
        expect { subject.publish }.to raise_exception(Messaging::MessageValidationError)
      end
    end

    context 'when message is valid' do
      before(:each) do
        allow(subject).to receive(:valid_message?).and_return(true)
      end

      let(:error_response) { Messaging::ProducerResponse.new(code: 500, body: '', description: 'test error') }
      let(:entry) { ExportedClaim.find_by(claim_uuid: claim.uuid) }

      # TODO: for now we don't care about SNS, and the code is getting very coupled to SOAP anyway. Revisit/refactor If we decide to use SNS.
      # context 'when using SNS producer' do
      #   before do
      #     Messaging::ClaimMessage.producer = Messaging::SNSProducer.new(client_class: Messaging::MockClient, queue: 'cccd-claims')
      #     create(:exported_claim, :enqueued, claim: claim)
      #   end
      #
      #   it 'should update the claim export database entry' do
      #     subject.publish
      #     expect(entry.status).to eq('published')
      #   end
      #
      #   context 'when there is an error in the publishing' do
      #     before(:each) do
      #       allow_any_instance_of(Messaging::MockClient).to receive(:build_response).and_return(error_response)
      #     end
      #
      #     it 'should update the claim export database entry with the error' do
      #       subject.publish
      #       expect(entry.status).to eq('publish_error')
      #       expect(entry.status_msg).to eq('test error')
      #     end
      #   end
      # end

      context 'when using HTTP producer' do
        before do
          Messaging::ClaimMessage.producer = Messaging::HttpProducer.new(:claim_request, client_class: Messaging::MockClient)
          create(:exported_claim, :enqueued, claim: claim)
        end

        context 'when the publishing was successful' do
          before(:each) do
            allow_any_instance_of(Messaging::ProducerResponse).to receive(:body).and_return(success_response_xml)
          end

          it 'should update the claim export database entry' do
            subject.publish
            expect(entry.status).to eq('published')
          end
        end

        context 'when there is an error in the publishing' do
          before(:each) do
            allow_any_instance_of(Messaging::MockClient).to receive(:build_response).and_return(error_response)
          end

          it 'should update the claim export database entry with the error' do
            subject.publish
            expect(entry.status).to eq('publish_error')
            expect(entry.status_msg).to eq('test error')
          end
        end
      end
    end
  end

  def success_response_xml
    <<-XML
    <?xml version="1.0" encoding="UTF-8"?>
    <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
      <!-- message simplified -->
      <SOAP-ENV:Body>
        <ClaimResponse>
          <ClaimUUID>fdf9958e-e221-40cf-a9d9-818f4a04e37e</ClaimUUID>
          <AckId>668747f7-4444-4294-8d41-ae66e3cd8f57</AckId>
        </ClaimResponse>
      </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>
    XML
  end
end
