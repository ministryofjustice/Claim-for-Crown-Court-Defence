describe API::Entities::OffenceClass do
  subject(:response) { JSON.parse(described_class.represent(offence_class).to_json).deep_symbolize_keys }

  let(:offence_class) { build(:offence_class) }
  let(:expected_keys) { %i[id class_letter description lgfs_offence_id] }

  it 'has expected json keys' do
    expect(response.keys).to include(*expected_keys)
  end
end
