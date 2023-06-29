RSpec.shared_examples 'geckoboard publishable report' do
  let(:client) { double Geckoboard::Client }
  let(:datasets_client) { double Geckoboard::DatasetsClient }
  let(:dataset) { double Geckoboard::Dataset }
  let(:logger) { double Rails.logger }
  let(:null_object) { double('null object').as_null_object }

  subject(:report) { described_class.new }

  it { expect(described_class).to have_constant name: :ITEMS_CHUNK_SIZE, value: 500 }
  it { expect(described_class).to have_constant name: :MAX_STRING_LENGTH, value: 100 }
  it { is_expected.to respond_to :client }
  it { is_expected.to respond_to :id }
  it { is_expected.to respond_to :fields }
  it { is_expected.to respond_to :publish! }
  it { is_expected.to respond_to :force? }
  it { is_expected.to respond_to :published? }

  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('ENV', nil).and_return 'staging'
    allow(ENV).to receive(:fetch).with('GECKOBOARD_API_KEY', nil).and_return 'fake-API-key'
    allow(client).to receive(:ping).and_return true
    allow(Geckoboard).to receive(:client).with('fake-API-key').and_return client
  end

  describe '#new' do
    it 'connects to geckoboard using API key stored in ENV variable' do
      expect { report }.not_to raise_error
    end

    it 'returns report instance on success' do
      expect(report).to be_instance_of described_class
    end

    it 'raises and logs error on failure' do
      allow(client).to receive(:ping).and_raise Geckoboard::UnauthorizedError
      expect(Rails).to receive(:logger).and_return logger
      expect(logger).to receive(:warn).with(/.*Geckoboard API key.*/)
      expect { report }.to raise_error Geckoboard::UnauthorizedError
    end
  end

  describe '#id' do
    it 'is specific to app, environment and report name' do
      expect(report.id).to eql "advocate_defence_payments-staging.#{described_class.name.demodulize.underscore}"
    end
  end

  describe '#publish!' do
    it 'creates (or finds) geckoboard dataset and replaces its data' do
      expect(report).to receive(:create_dataset!)
      expect(report).to receive(:add_to_dataset!).and_return true
      expect(report.publish!).to be true
    end

    context 'handles conflict errors' do
      before do
        allow(client).to receive(:datasets).and_return datasets_client
        allow(datasets_client).to receive(:find_or_create).with(any_args).and_raise Geckoboard::ConflictError
      end

      it 'by overwriting existing dataset when force specified' do
        expect(report).to receive(:overwrite!)
        report.publish! force: true
      end

      it 'by raising errors when force not specified' do
        expect(report).not_to receive(:overwrite!)
        expect { report.publish! }.to raise_error Geckoboard::ConflictError
      end
    end
  end

  describe '#unpublish!' do
    context 'when dataset exists' do
      it 'deletes the dataset and returns true' do
        expect(client).to receive(:datasets).and_return dataset
        expect(dataset).to receive(:delete).and_return true
        expect(report.unpublish!).to be true
      end
    end

    context 'when dataset does not exist' do
      it 'returns false' do
        expect(client).to receive(:datasets).and_return dataset
        expect(dataset).to receive(:delete).and_raise Geckoboard::UnexpectedStatusError
        expect(report.unpublish!).to be false
      end
    end
  end
end

RSpec.shared_examples 'returns valid items structure' do
  it 'returns a geckoboard compatible format' do
    is_expected.to be_an(Array)
    expect(subject.first).to be_a(Hash)
    expect { subject.to_json }.not_to raise_error
  end

  it 'returns dataset which matches field definitions' do
    fields = described_class.new.fields
    expect(subject.first.keys).to match_array fields.map(&:id)
  end
end

RSpec.shared_examples 'a disabler of view only actions' do
  specify { expect(assigns(:disable_analytics)).to be_truthy }
  specify { expect(assigns(:disable_phase_banner)).to be_truthy }
  specify { expect(assigns(:disable_flashes)).to be_truthy }
end
