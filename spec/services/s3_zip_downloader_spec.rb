require 'rails_helper'

RSpec.describe S3ZipDownloader do
  subject(:s3_zip_downloader) { described_class.new(claim) }

  let!(:claim) { create :claim }
  let!(:document) { create :document, :verified, claim: claim }

  describe 'generate!' do
    subject(:generate!) { s3_zip_downloader.generate! }

    it { is_expected.to be_a Zip::File }
  end
end
