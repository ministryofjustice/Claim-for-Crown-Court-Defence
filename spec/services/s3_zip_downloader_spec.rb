require 'rails_helper'

RSpec.describe S3ZipDownloader do
  let(:s3_zip_downloader) { described_class.new(claim) }
  let(:claim) { create :claim }

  before { create :document, :verified, claim: claim }

  describe '#generate!' do
    subject(:generated_file) { s3_zip_downloader.generate! }

    it { is_expected.to be_a String }
    it { expect(File).to exist(generated_file) }
  end
end
