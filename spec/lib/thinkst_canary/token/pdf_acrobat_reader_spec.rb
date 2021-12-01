require 'rails_helper'
require 'lib/thinkst_canary/token/shared_examples'

RSpec.describe ThinkstCanary::Token::PdfAcrobatReader do
  include_examples 'a Canary token', 'pdf-acrobat-reader' do
    let(:file_upload) { instance_double(Faraday::UploadIO) }
    let(:extra_token_options) { { file: StringIO.new } }
    let(:extra_request_options) { { pdf: file_upload } }

    before { allow(Faraday::UploadIO).to receive(:new).and_return(file_upload) }
  end

  include_examples 'a Canary token with a file'
end
