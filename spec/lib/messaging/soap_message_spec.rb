require 'rails_helper'

describe Messaging::SOAPMessage do
  let(:claim) { create(:deterministic_claim, :redetermination) }
  let(:message_uuid) { '111-222-333' }

  subject { described_class.new(claim) }

  before(:each) do
    allow(subject).to receive(:message_uuid).and_return(message_uuid)
  end

  after(:all) do
    clean_database
  end

  it 'should produce a valid SOAP message' do
    message_xml = subject.to_xml
    message_hash = Hash.from_xml(message_xml)
    expected_hash = Hash.from_xml(expected_xml)

    # We ignore on purpose the claim details to simplify this test
    message_hash['Envelope']['Body']['claim_request'] = {'xmlns:cbo' => 'http://www.justice.gov.uk/2016/11/cbo'}

    expect(message_hash).to eq(expected_hash)
  end

  let(:expected_xml) do
    <<-XML
    <?xml version="1.0" encoding="UTF-8"?>
    <soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope">
      <soapenv:Header xmlns:wsa="http://www.w3.org/2005/08/addressing">
        <wsa:Action soapenv:mustUnderstand="1">newCBOClaim</wsa:Action>
        <wsa:From soapenv:mustUnderstand="1">
          <wsa:Address>http://cob.gov.uk/cccd</wsa:Address>
        </wsa:From>
        <wsa:MessageID soapenv:mustUnderstand="1">uuid:111-222-333</wsa:MessageID>
        <wsa:To soapenv:mustUnderstand="1">http://legalaid.gov.uk/infoX/gateway/ccr</wsa:To>
      </soapenv:Header>
      <soapenv:Body>
        <cbo:claim_request xmlns:cbo="http://www.justice.gov.uk/2016/11/cbo"/>
      </soapenv:Body>
    </soapenv:Envelope>
    XML
  end
end
