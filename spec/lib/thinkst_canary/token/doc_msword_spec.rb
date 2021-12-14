require 'rails_helper'
require 'lib/thinkst_canary/token/shared_examples'

RSpec.describe ThinkstCanary::Token::DocMsword do
  include_examples 'a Canary token with a file', 'doc-msword', :doc
end
