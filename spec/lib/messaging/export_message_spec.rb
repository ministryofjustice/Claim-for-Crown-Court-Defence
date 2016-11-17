require 'rails_helper'

describe Messaging::ExportMessage do
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
    <env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope">
      <env:Header xmlns:wsa="http://www.w3.org/2005/08/addressing">
        <wsa:To env:mustUnderstand="1">http://legalaid.gov.uk/infoX/gateway/ccr</wsa:To>
        <wsa:From env:mustUnderstand="1">
          <wsa:Address>http://cob.gov.uk/cccd</wsa:Address>
        </wsa:From>
        <wsa:Action>newCBOClaim</wsa:Action>
        <wsa:MessageID>uuid:111-222-333</wsa:MessageID>
      </env:Header>
      <env:Body>
        <cbo:claim_request xmlns:cbo="http://www.justice.gov.uk/2016/11/cbo"/>
      </env:Body>
    </env:Envelope>
    XML
  end
end
