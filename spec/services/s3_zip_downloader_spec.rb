require 'rails_helper'

RSpec.describe S3ZipDownloader do
  let(:s3_zip_downloader) { described_class.new(claim) }
  let(:claim) { create(:claim) }

  describe '#generate!' do
    subject(:generated_file) { s3_zip_downloader.generate! }

    context 'with evidence documents' do
      before { create(:document, :verified, claim:) }

      it { is_expected.to be_a String }
      it { expect(File).to exist(generated_file) }
    end

    context 'with two files with the same name' do
      before { create_list(:document, 2, :verified, claim:, filename: 'testfile.pdf') }

      it { expect { generated_file }.not_to raise_error }
    end
  end
end
