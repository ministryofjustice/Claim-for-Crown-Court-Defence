RSpec.shared_examples 'successful fee calculator response' do
  it 'returns success? true' do
    expect(response.success?).to be true
  end

  it 'returns amount' do
    expect(response.data.amount).to be_kind_of Float
  end

  it 'returns no errors' do
    expect(response.errors).to be_nil
  end

  it 'returns no messages' do
    expect(response.message).to be_nil
  end
end

RSpec.shared_examples 'failed fee calculator response' do
  it 'returns success? false' do
    expect(response.success?).to be false
  end

  it 'returns no data' do
    expect(response.data).to be_nil
  end

  it 'returns errors' do
    expect(response.errors).to be_an Array
  end

  it 'returns messages' do
    expect(response.message).to be_a String
  end
end

RSpec.shared_examples 'fee calculator amount' do |options|
  let(:expected_amount) { options.fetch(:amount, nil) }

  it 'returns non-zero amount' do
    expect(response.data.amount).to be > 0
  end

  # TODO: maybe too much integration??
  if options&.fetch(:amount)
    it 'returns expected amount' do
      expect(response.data.amount).to be expected_amount
    end
  end
end
