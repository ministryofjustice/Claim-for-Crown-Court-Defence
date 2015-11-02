require 'rails_helper'

describe ErrorDetail do

  let(:ed0) { ErrorDetail.new(:key0,'long error',  'short error') }
  let(:ed1) { ErrorDetail.new(:key3,'long error',  'short error', 10) }
  let(:ed2) { ErrorDetail.new(:key2,'long error',  'short error', 11) }
  let(:ed3) { ErrorDetail.new(:key1,'long error',  'short error', 12) }
  let(:ed4) { ErrorDetail.new(:key1,'long error',  'short error', 12) }
  let(:ed5) { ErrorDetail.new(:key1,'long error',  'different short error', 12) }
  let(:ed6) { ErrorDetail.new(:key1,'different long error',  'short error', 12) }

  it 'stores attribute against a long message, short message and ordering sequence' do
    expect(ed0).to respond_to :attribute
    expect(ed0).to respond_to :long_message
    expect(ed0).to respond_to :short_message
    expect(ed0).to respond_to :sequence
  end

  it 'defaults sequence to 99999' do
    expect(ed0.sequence).to eql 99999
  end

  it 'sorts against other ErrorDetail instances by sequence' do
    expect([ed1,ed2].sort!).to eql [ed1,ed2]
  end

  it 'compares all attributes for eqaulity' do
    expect(ed1==ed2).to eql false
    expect(ed3==ed4).to eql true
    expect(ed3==ed5).to eql false
    expect(ed3==ed6).to eql false
  end

end
