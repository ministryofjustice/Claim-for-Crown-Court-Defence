require 'rails_helper'

describe Messaging::ClaimMessage do
  let(:claim) { create(:authorised_claim) }

  subject { described_class.new(claim) }

  it 'should have a subject' do
    expect(subject.subject).to eq('Claim UUID %s' % claim.uuid)
  end

  it 'should have a message' do
    expect(subject.message).to match(/<claim_details>/)
  end

  it 'should publish' do
    expect_any_instance_of(Messaging::Producer).to receive(:publish).with(hash_including(:subject, :message))
    subject.publish
  end
end
