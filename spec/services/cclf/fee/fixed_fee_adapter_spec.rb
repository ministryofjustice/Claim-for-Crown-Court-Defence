require 'rails_helper'
require 'spec_helper'
require_relative 'shared_examples_for_cclf_fee_entities'

RSpec.describe CCLF::Fee::FixedFeeAdapter, type: :adapter do
  FIXED_FEE_BILL_SCENARIOS = {
    FXACV: 'ST1TS0T5', # Appeal against conviction
    FXASE: 'ST1TS0T6', # Appeal against sentence
    FXCBR: 'ST3TS3TB', # Breach of Crown Court order
    FXCSE: 'ST1TS0T7', # Committal for Sentence
    FXCON: 'ST1TS0T8', # Contempt
    FXENP: 'ST4TS0T1', # Elected cases not proceeded
    FXH2S: 'ST1TS0TC', # Hearing subsequent to sentence
  }.freeze

  it_behaves_like 'Litigator Fee Adapter', FIXED_FEE_BILL_SCENARIOS
end
