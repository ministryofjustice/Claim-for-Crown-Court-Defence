RSpec.describe Claims::FeeCalculator::Request do
  subject { described_class.new(service) }

  let(:service) { instance_double(Claims::FeeCalculator::GraduatedPrice, amount: 130.00) }

  it { is_expected.to respond_to(:service) }
  it { is_expected.to respond_to(:call) }

  describe '#call' do
    subject(:call) { described_class.new(service).call }

    it 'calls service#amount' do
      expect(service).to receive(:amount)
      call
    end

    context 'when successful' do
      context 'when amount is a Float' do
        let(:service) { instance_double(Claims::FeeCalculator::GraduatedPrice, amount: 1632.00) }

        it { is_expected.to be_a Claims::FeeCalculator::Response }
        it { is_expected.to have_attributes(success?: true, data: instance_of(described_class::Data), errors: nil, message: nil) }
        it { expect(call.data).to have_attributes(amount: 1632.00, unit: nil) }
      end

      context 'when amount is a Price' do
        let(:service) { instance_double(Claims::FeeCalculator::UnitPrice, amount: price) }
        let(:price) { Claims::FeeCalculator::Price.new({}, nil, 1) }

        before do
          allow(price).to receive_messages(per_unit: 26.00, unit: 'day')
        end

        it { is_expected.to be_a Claims::FeeCalculator::Response }
        it { is_expected.to have_attributes(success?: true, data: instance_of(described_class::Data), errors: nil, message: nil) }
        it { expect(call.data).to have_attributes(amount: 26.00, unit: 'day') }
      end
    end

    context 'when error raised' do
      before do
        allow_any_instance_of(described_class).to receive(:data).and_raise(Claims::FeeCalculator::Exceptions::PriceNotFound)
      end

      it { is_expected.to be_a Claims::FeeCalculator::Response }
      it { is_expected.to have_attributes(success?: false, data: nil, errors: instance_of(Array), message: instance_of(String)) }
    end
  end
end
