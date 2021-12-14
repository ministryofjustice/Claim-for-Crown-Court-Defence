require 'rails_helper'
require 'lib/thinkst_canary/token/shared_examples'

RSpec.describe ThinkstCanary::Token::PdfAcrobatReader do
  include_examples 'a Canary token with a file', 'pdf-acrobat-reader', :pdf
end
