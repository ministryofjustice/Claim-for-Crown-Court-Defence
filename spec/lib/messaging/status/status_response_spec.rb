require 'rails_helper'

describe Messaging::Status::StatusResponse do
  let(:ack_id) { '6c80319d-3e9e-4c78-add6-8c896c56be04' }
  let(:claim_uuid) { '08ce9459-b34b-4af5-a7f5-c178f7990b0c' }

  subject { described_class.new(response) }

  describe 'success response' do
    let(:response) { success_response_xml }

    it 'populates the ack_id attribute' do
      expect(subject.ack_id).to eq(ack_id)
    end

    it 'populates the claim_uuid attribute' do
      expect(subject.claim_uuid).to eq(claim_uuid)
    end

    it 'populates the processing_result attribute' do
      expect(subject.processing_result).to eq(true)
    end

    it 'populates the errors attribute' do
      expect(subject.errors).to eq([])
    end
  end

  describe 'failure response' do
    let(:response) { error_response_xml }

    it 'populates the ack_id attribute' do
      expect(subject.ack_id).to eq(ack_id)
    end

    it 'populates the claim_uuid attribute' do
      expect(subject.claim_uuid).to eq(claim_uuid)
    end

    it 'populates the processing_result attribute' do
      expect(subject.processing_result).to eq(false)
    end

    it 'populates the errors attribute' do
      expect(subject.errors).to eq([{code: 100, detail: 'Detail of the 100 error'}, {code: 200, detail: 'Detail of the 200 error'}])
    end
  end

  #------------------------------------------------------
  #
  def success_response_xml
    <<-XML
    <?xml version="1.0" encoding="UTF-8"?>
    <claim>
      <ack_id>#{ack_id}</ack_id>
      <claim_details>
        <uuid>#{claim_uuid}</uuid>
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
      <ack_id>#{ack_id}</ack_id>
      <claim_details>
        <uuid>#{claim_uuid}</uuid>
      </claim_details>
      <processing_result>
        <success>false</success>
        <errors>
          <error>
            <code>100</code>
            <detail>Detail of the 100 error</detail>
          </error>
          <error>
            <code>200</code>
            <detail>Detail of the 200 error</detail>
          </error>
        </errors>
      </processing_result>
    </claim>
    XML
  end
end
