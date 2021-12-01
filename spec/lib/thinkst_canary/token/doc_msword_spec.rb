require 'rails_helper'
require 'lib/thinkst_canary/token/shared_examples'

RSpec.describe ThinkstCanary::Token::DocMsword do
  include_examples 'a Canary token', 'doc-msword' do
    let(:file_upload) { instance_double(Faraday::UploadIO) }
    let(:extra_token_options) { { file: StringIO.new } }
    let(:extra_request_options) { { doc: file_upload } }

    before { allow(Faraday::UploadIO).to receive(:new).and_return(file_upload) }
  end

  include_examples 'a Canary token with a file'
end
