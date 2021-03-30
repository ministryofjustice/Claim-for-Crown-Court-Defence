require 'rails_helper'

RSpec.describe DocumentConverterService do
  subject(:convert_document) { described_class.new(document, new_document).call }

  let(:document) { message.attachment }
  let(:new_document) { build(:message).attachment }
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
    let(:message) { build :message, :with_pdf_attachment }

    before { convert_document }

    it { expect(new_document.blob).to eq document.blob }
  end

  context 'when the source attachment has been saved' do
    let(:message) { create :message, :with_docx_attachment }

    before { convert_document }

    it { expect(new_document.content_type).to eq 'application/pdf' }
    it { expect(new_document.checksum).to eq checksum }
  end

  context 'when the source attachment is new (i.e., not saved)' do
    let(:message) { build :message, :with_docx_attachment }

    before { convert_document }

    it { expect(new_document.content_type).to eq 'application/pdf' }
    it { expect(new_document.checksum).to eq checksum }
  end
end
