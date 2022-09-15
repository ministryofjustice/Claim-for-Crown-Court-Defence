RSpec.shared_examples 'a successful fee calculator response' do |options|
  # Singleton class requires reset before use
  # rubocop:disable RSpec/BeforeAfterAll
  before(:all) { Claims::FeeCalculator::FeeTypeMappings.reset }
  # rubocop:enable RSpec/BeforeAfterAll

  before do
    number_of_defendants = options&.fetch(:number_of_defendants, nil)
    if number_of_defendants
      needed = number_of_defendants - claim.defendants.count
      needed.times do
        claim.defendants << create(:defendant, scheme: options&.fetch(:scheme))
      end
    end
  end

  it 'returns success? true' do
    expect(response.success?).to be true
  end

  it 'includes unit' do
    unit = options&.fetch(:unit, nil)
    if unit
      expect(response.data.unit).to be_a String
      expect(response.data.unit).to match(unit.upcase)
    else
      expect(response.data.unit).to be_nil
    end
  end

  it 'includes amount' do
    expect(response.data.amount).to be_a Float
  end

  if options&.fetch(:amount, nil)
    it "includes expected amount #{options&.fetch(:amount)}" do
      amount = options&.fetch(:amount)
      expect(response.data.amount).to eq amount
    end
  end

  it 'includes no errors' do
    expect(response.errors).to be_nil
  end

  it 'includes no error message' do
    expect(response.message).to be_nil
  end
end

RSpec.shared_examples 'a failed fee calculator response' do |options|
  # Singleton class requires reset before use
  # rubocop:disable RSpec/BeforeAfterAll
  before(:all) { Claims::FeeCalculator::FeeTypeMappings.reset }
  # rubocop:enable RSpec/BeforeAfterAll

  it 'includes success? false' do
    expect(response.success?).to be false
  end

  it 'includes no data' do
    expect(response.data).to be_nil
  end

  it 'includes errors' do
    expect(response.errors).to be_an Array
  end

  it 'includes error message' do
    expect(response.message).to be_a String
  end

  if options&.fetch(:message)
    it { is_expected.to include_fee_calc_error(options&.fetch(:message)) }
  end
end
