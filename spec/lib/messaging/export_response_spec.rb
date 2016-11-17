require 'rails_helper'

describe Messaging::ExportResponse do
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

    it 'status is published' do
      expect(subject.status).to eq('published')
    end

    it 'success?' do
      expect(subject.success?).to be_truthy
    end

    it 'error?' do
      expect(subject.error?).to be_falsey
    end
  end

  describe 'failure response' do
    let(:response) { error_response_xml }

    it 'populates the error_code attribute' do
      expect(subject.error_code).to eq('SOAP-ENV:Server')
    end

    it 'populates the error_message attribute' do
      expect(subject.error_message).to eq('Could not get JDBC Connection')
    end

    it 'status is the error code' do
      expect(subject.status).to eq('SOAP-ENV:Server')
    end

    it 'success?' do
      expect(subject.success?).to be_falsey
    end

    it 'error?' do
      expect(subject.error?).to be_truthy
    end
  end

  #------------------------------------------------------
  #
  def success_response_xml
    <<-XML
    <?xml version="1.0" encoding="UTF-8"?>
    <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
      <SOAP-ENV:Header xmlns:wsa="http://www.w3.org/2005/08/addressing">
        <wsa:To SOAP-ENV:mustUnderstand="1">http://www.w3.org/2005/08/addressing/anonymous</wsa:To>
        <wsa:Action>cbonewclaimResponse</wsa:Action>
        <wsa:MessageID>fdf9958e-e221-40cf-a9d9-818f4a04e37e</wsa:MessageID>
        <wsa:RelatesTo>668747f7-4444-4294-8d41-ae66e3cd8f57</wsa:RelatesTo>
      </SOAP-ENV:Header>
      <SOAP-ENV:Body>
        <ClaimResponse>
          <ClaimUUID>#{claim_uuid}</ClaimUUID>
          <AckId>#{ack_id}</AckId>
        </ClaimResponse>
      </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>
    XML
  end

  def error_response_xml
    <<-XML
    <?xml version="1.0" encoding="UTF-8"?>
    <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
      <SOAP-ENV:Header xmlns:wsa="http://www.w3.org/2005/08/addressing">
        <wsa:To SOAP-ENV:mustUnderstand="1">http://www.w3.org/2005/08/addressing/anonymous</wsa:To>
        <wsa:Action>cbonewclaimResponse</wsa:Action>
        <wsa:MessageID>4fc522b6-1390-4314-941c-0ff67b9fec06</wsa:MessageID>
        <wsa:RelatesTo>668747f7-4444-4291-8d40-ae66e3cd8f57</wsa:RelatesTo>
      </SOAP-ENV:Header>
      <SOAP-ENV:Body>
        <SOAP-ENV:Fault>
          <faultcode>SOAP-ENV:Server</faultcode>
          <faultstring xml:lang="en">Could not get JDBC Connection</faultstring>
        </SOAP-ENV:Fault>
      </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>
    XML
  end
end
