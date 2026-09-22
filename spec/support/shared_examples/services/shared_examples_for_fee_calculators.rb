RSpec.shared_examples 'a successful fee calculator response' do |options|
  # Singleton class requires reset before use
  before { Claims::FeeCalculator::FeeTypeMappings.reset }

  before do
    number_of_defendants = options&.fetch(:number_of_defendants, nil)
    if number_of_defendants
      needed = number_of_defendants - claim.defendants.count
      needed.times do
        claim.defendants << create(:defendant, scheme: options&.fetch(:scheme))
      end
    end
  end

  it 'returns the expected response', :aggregate_failures do
    expect(response.success?).to be true

    unit = options&.fetch(:unit, nil)
    if unit
      expect(response.data.unit).to be_a String
      expect(response.data.unit).to match(unit.upcase)
    else
      expect(response.data.unit).to be_nil
    end

    expect(response.data.amount).to be_a Float
    expect(response.data.amount).to eq(options.fetch(:amount)) if options&.fetch(:amount, nil)
    expect(response.errors).to be_nil
    expect(response.message).to be_nil
  end
end

RSpec.shared_examples 'a failed fee calculator response' do |options|
  # Singleton class requires reset before use
  before { Claims::FeeCalculator::FeeTypeMappings.reset }

  it 'returns the expected response', :aggregate_failures do
    expect(response.success?).to be false
    expect(response.data).to be_nil
    expect(response.errors).to be_an Array
    expect(response.message).to be_a String
    expect(response).to include_fee_calc_error(options&.fetch(:message)) if options&.fetch(:message)
  end
end
