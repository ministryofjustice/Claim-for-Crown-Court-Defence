require 'rails_helper'

RSpec.shared_examples 'add_checksum failure cases' do
  before { stub_const('TestClass', test_class) }

  it 'does not raise an error' do
    expect { add_checksum }.not_to raise_error
  end

  it 'logs the error' do
    allow(LogStuff).to receive(:warn)
    add_checksum
    expect(LogStuff).to have_received(:warn)
      .with(hash_including(class: 'TestClass', action: 'add_checksum'))
  end
end

RSpec.describe CheckSummable do
  let(:test_object) { test_class.new }
  let(:checksum) { Digest::MD5.new.tap { |digest| digest << 'Test document' }.base64digest }
  let(:io) { StringIO.new('Test document') }
  let(:test_class) do
    Class.new do
      include CheckSummable

      attr_accessor :as_document_checksum

      def document
        @document ||= OpenStruct.new(path: 'example.pdf')
      end
    end
  end

  describe '#calculate_checksum' do
    subject(:calculate_checksum) { test_object.calculate_checksum(io) }

    context 'with a valid io stream' do
      it { is_expected.to eq checksum }

      it 'rewinds the io stream' do
        expect { calculate_checksum }.not_to change(io, :readline)
      end
    end

    context 'with a nil io stream' do
      let(:io) { nil }

      it 'is nil if the input stream is nil' do
        expect(calculate_checksum).to be_nil
      end
    end
  end

  describe '#add_checksum' do
    subject(:add_checksum) { test_object.add_checksum('document') }

    let(:registry) { Paperclip::AdapterRegistry.new }

    before { allow(Paperclip).to receive(:io_adapters).and_return(registry) }

    context 'with a good file' do
      before do
        allow(registry).to receive(:for).with(test_object.document).and_return(io)
      end

      it 'sets the checksum' do
        expect { add_checksum }.to change(test_object, :as_document_checksum).to checksum
      end
    end

    context 'with a missing file' do
      before do
        allow(registry).to receive(:for).with(test_object.document).and_raise(Errno::ENOENT)
      end

      include_examples 'add_checksum failure cases'
    end

    context 'with a filename too long' do
      before do
        allow(registry).to receive(:for).with(test_object.document).and_raise(Errno::ENAMETOOLONG)
      end

      include_examples 'add_checksum failure cases'
    end

    context 'with an unexpected error' do
      before do
        allow(registry).to receive(:for).with(test_object.document).and_raise(StandardError)
      end

      include_examples 'add_checksum failure cases'
    end
  end
end
