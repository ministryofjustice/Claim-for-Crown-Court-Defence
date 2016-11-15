require 'rails_helper'

describe Messaging::Status::StatusUpdater do
  let(:uuid) { '08ce9459-b34b-4af5-a7f5-c178f7990b0c' }
  let(:response) { success_response_xml }

  subject { described_class.new }

  before(:each) do
    allow(subject).to receive(:pending_claim_uuids).and_return([uuid])
    allow(subject).to receive(:client).and_return(double(post: response))
  end

  it 'should build the expect payload' do
    expect(subject.payload).to match(/<cbo:ClaimUUID>#{uuid}<\/cbo:ClaimUUID>/)
  end

  describe 'updating the exported claim database record' do
    let(:exported_claim) { create(:exported_claim, claim_uuid: uuid) }

    before(:each) { ExportedClaim.delete_all }

    context 'for a successful response' do
      let(:response) { success_response_xml }

      it 'should update the database record' do
        expect(exported_claim.status).to be_nil
        subject.run
        exported_claim.reload
        expect(exported_claim.status).to eq('success')
      end
    end

    context 'for a failure response' do
      let(:response) { error_response_xml }

      it 'should update the database record' do
        expect(exported_claim.status).to be_nil
        subject.run
        exported_claim.reload
        expect(exported_claim.status).to eq('error')
      end
    end
  end

  #------------------------------------------------------
  #
  def success_response_xml
    <<-XML
    <?xml version="1.0" encoding="UTF-8"?>
    <claim>
      <ack_id>6c80319d-3e9e-4c78-add6-8c896c56be04</ack_id>
      <claim_details>
        <uuid>#{uuid}</uuid>
      </claim_details>
      <processing_result>
        <success>true</success>
      </processing_result>
    </claim>
    XML
  end

  def error_response_xml
    <<-XML
    <?xml version="1.0" encoding="UTF-8"?>
    <claim>
      <ack_id>6c80319d-3e9e-4c78-add6-8c896c56be04</ack_id>
      <claim_details>
        <uuid>#{uuid}</uuid>
      </claim_details>
      <processing_result>
        <success>false</success>
        <errors>
          <error>
            <code>100</code>
            <detail>Detail of the error goes here</detail>
          </error>
          <error>
            <code>200</code>
            <detail>Detail of the 200 error code goes here</detail>
          </error>
        </errors>
      </processing_result>
    </claim>
    XML
  end
end

