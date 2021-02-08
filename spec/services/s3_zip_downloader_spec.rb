require 'rails_helper'

RSpec.describe S3ZipDownloader do
  let(:s3_zip_downloader) { described_class.new(claim) }

  let!(:claim) { create :claim }
  let!(:document) { create :document, :verified, claim: claim }

  describe 'generate!' do
    subject(:generated_file) { s3_zip_downloader.generate! }

    it 'returns the zip filename' do
      expect(generated_file).to be_a String
    end

    it 'creates the zip file' do
      expect(File).to exist(generated_file)
    end
  end
end
