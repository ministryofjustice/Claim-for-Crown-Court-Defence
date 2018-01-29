require 'rails_helper'
require 'spec_helper'
require_relative 'shared_examples_for_ccl_fee_entities'

module CCLF
  module Fee
    describe FixedFeeAdapter, type: :adapter do
      FIXED_FEE_BILL_SCENARIOS = {
        FXACV: 'ST1TS0T5', # Appeal against conviction
        FXASE: 'ST1TS0T6', # Appeal against sentence
        FXCBR: 'ST3TS3TB', # Breach of Crown Court order
        FXCSE: 'ST1TS0T7', # Committal for Sentence
        FXCON: 'ST1TS0T8', # Contempt
        FXENP: 'ST4TS0T1', # Elected cases not proceeded
        FXH2S: 'ST1TS0TC', # Hearing subsequent to sentence
      }.freeze

      it_behaves_like 'CCLF Litigator Fee entity', FIXED_FEE_BILL_SCENARIOS
    end
  end
end
