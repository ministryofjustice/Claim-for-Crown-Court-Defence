require 'rails_helper'

RSpec.describe ConvertDocumentJob, type: :job do
  let(:job) { described_class.new }

  describe '#perform' do
    subject(:perform) { job.perform(document.to_param) }

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

    context 'with an existing converted preview document' do
      let(:document) { create :document, :with_preview }

      it { expect { perform }.not_to(change { document.reload.converted_preview_document }) }
      it { expect { perform }.not_to raise_error }
    end

    context 'with a pdf document' do
      let(:document) { create :document, :pdf }

      it do
        expect { perform }
          .to change { document.reload.converted_preview_document&.attachment&.blob }.to document.document.blob
      end

      it { expect { perform }.not_to raise_error }
    end

    context 'with a docx document' do
      let(:document) { create :document, :docx }

      it do
        expect { perform }
          .to change { document.reload.converted_preview_document&.attachment&.content_type }.to 'application/pdf'
      end

      it { expect { perform }.not_to raise_error }
    end

    context 'when Libreconv fails' do
      let(:document) { create :document, :docx }

      before { allow(Libreconv).to receive(:convert).and_raise(IOError) }

      it { expect { perform }.to raise_error(IOError) }
    end

    context 'when allowing for Paperclip rollback' do
      let(:document) { create :document, :docx }

      it do
        expect { perform }
          .to change { document.reload.converted_preview_document_file_name }
          .to "#{document.document_file_name}.pdf"
      end

      it do
        expect { perform }
          .to change { document.reload.converted_preview_document_content_type }
          .to 'application/pdf'
      end

      it { expect { perform }.to(change { document.reload.converted_preview_document_updated_at }) }
      it { expect { perform }.to(change { document.reload.converted_preview_document_file_size }) }
      it { expect { perform }.to(change { document.reload.as_converted_preview_document_checksum }) }
    end
  end
end
