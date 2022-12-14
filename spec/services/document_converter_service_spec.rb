require 'rails_helper'

RSpec.describe DocumentConverterService do
  subject(:convert_document) { described_class.new(attachment, converted_attachment).call }

  let(:attachment) { document.document }
  let(:converted_attachment) { document.converted_preview_document }
  let(:checksum) { 'LmC+AfCP6+Q69vCYuAt7rQ==' } # Checksum of shorter_lorem.pdf

  before do
    allow(Libreconv).to receive(:convert).with(anything, anything) do |from_file, to_file|
      if File.exist?(from_file)
        File.open(File.expand_path('features/examples/shorter_lorem.pdf', Rails.root)) do |input_stream|
          File.open(to_file, 'wb') do |output_stream|
            IO.copy_stream(input_stream, output_stream)
          end
        end
      end
    end
  end

  context 'when the source attachment is a PDF' do
    let(:document) { build(:document, :pdf) }

    before { convert_document }

    it { expect(converted_attachment.blob).to eq attachment.blob }
  end

  context 'when the source attachment has been saved' do
    let(:document) { create(:document, :docx) }

    before { convert_document }

    it { expect(converted_attachment.content_type).to eq 'application/pdf' }
    it { expect(converted_attachment.checksum).to eq checksum }
  end

  context 'when the source attachment is new (i.e., not saved)' do
    let(:document) { build(:document, :docx) }

    before { convert_document }

    it { expect(converted_attachment.content_type).to eq 'application/pdf' }
    it { expect(converted_attachment.checksum).to eq checksum }
  end
end
