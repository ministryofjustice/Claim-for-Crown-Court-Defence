require 'rails_helper'

RSpec.describe ConvertDocumentJob, type: :job do
  subject(:job) { described_class.new }

  describe '#perform' do
    subject(:perform) { job.perform(document.id) }

    context 'with an existing converted preview document' do
      let(:document) { create :document, :with_preview }

      it { expect { perform }.not_to(change { document.reload.converted_preview_document_file_name }) }
      it { expect { perform }.not_to raise_error }
    end

    context 'with a pdf document' do
      let(:document) { create :document, :pdf }

      it { expect { perform }.to change { document.reload.converted_preview_document.path }.to(document.document.path) }
      it { expect { perform }.not_to raise_error }

      it do
        expect { perform }
          .to change { document.reload.as_converted_preview_document_checksum }
          .to(document.as_document_checksum)
      end
    end

    context 'with a docx document' do
      let(:document) { create :document, :docx }

      before do
        allow(Libreconv).to receive(:convert).with(any_args) do |_file_in, file_out|
          File.open(Rails.root + 'features/examples/longer_lorem.pdf', 'rb') do |input|
            while (buff = input.read(4096))
              file_out.write(buff)
            end
          end
        end
      end

      it do
        expect { perform }
          .to change { document.reload.converted_preview_document_file_name }.to(document.document_file_name + '.pdf')
      end

      it do
        expect { perform }
          .to change { document.reload.converted_preview_document_content_type }.to('application/pdf')
      end

      it { expect { perform }.not_to raise_error }

      it do
        expect { perform }
          .to change { document.reload.as_converted_preview_document_checksum }
          .to('VJnssr9u1aT2uVBaTtQ7eQ==')
      end
    end

    context 'when Libreconv fails' do
      let(:document) { create :document, :docx }

      before { allow(Libreconv).to receive(:convert).and_raise(IOError) }

      it { expect { perform }.to raise_error(IOError) }
    end
  end
end
