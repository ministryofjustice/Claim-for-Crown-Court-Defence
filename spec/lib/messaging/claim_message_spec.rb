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

      context 'when using SNS producer' do
        before do
          Messaging::ClaimMessage.producer = Messaging::SNSProducer.new(client_class: Messaging::MockClient, queue: 'cccd-claims')
        end

        it 'should publish' do
          expect_any_instance_of(Messaging::SNSProducer).to receive(:publish)
          subject.publish
        end

        it 'should create an export database entry' do
          subject.publish
          entry = ExportedClaim.find_by(claim_uuid: claim.uuid)
          expect(entry).not_to be_nil
        end
      end

      context 'when using HTTP producer' do
        before do
          Messaging::ClaimMessage.producer = Messaging::HttpProducer.new(:claim_request, client_class: Messaging::MockClient)
        end

        it 'should publish' do
          expect_any_instance_of(Messaging::HttpProducer).to receive(:publish)
          subject.publish
        end

        it 'should create an export database entry' do
          subject.publish
          entry = ExportedClaim.find_by(claim_uuid: claim.uuid)
          expect(entry).not_to be_nil
        end
      end
    end
  end
end
