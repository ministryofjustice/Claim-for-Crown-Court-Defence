shared_examples_for 'an adapted expense' do
  it 'generates the expected rate' do
    expect(subject.rate.to_s).to match test[:expected_return][:rate]
  end
  it 'generates the expected quantity' do
    expect(subject.quantity.to_s).to match test[:expected_return][:quantity]
  end
  it 'generates the expected description' do
    expect(subject.description).to match test[:expected_return][:description]
  end
  it 'generates the expected bill_type' do
    expect(subject.bill_type).to match test[:expected_return][:bill_type]
  end
  it 'generates the expected bill_subtype' do
    expect(subject.bill_subtype).to match test[:expected_return][:bill_subtype]
  end
end
