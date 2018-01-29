require 'rails_helper'
require 'spec_helper'
require_relative 'shared_examples_for_ccl_fee_entities'

module CCLF
  module Fee
    describe GraduatedFeeAdapter, type: :adapter do
      GRADUATED_FEE_BILL_SCENARIOS = {
        GRDIS: 'ST1TS0T1', # Discontinuance
        GRGLT: 'ST1TS0T2', # Guilty plea
        GRTRL: 'ST1TS0T4', # Trial
        GRRTR: 'ST1TS0TA', # Retrial
        GRRAK: 'ST1TS0T3', # Cracked trial
        GRCBR: 'ST1TS0T9', # Cracked before retrial
      }.freeze

      it_behaves_like 'CCLF Litigator Fee entity', GRADUATED_FEE_BILL_SCENARIOS
    end
  end
end
