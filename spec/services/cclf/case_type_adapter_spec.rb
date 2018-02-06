require 'rails_helper'

RSpec.describe CCLF::CaseTypeAdapter, type: :adapter do
  let(:case_type) { instance_double('case_type') }

  describe '#bill_scenario' do
    subject { described_class.new(case_type).bill_scenario }

    context 'mappings' do
      final_claim_bill_scenarios.each do |code, scenario|
        context "maps #{code} to #{scenario}" do
          before do
            allow(case_type).to receive(:fee_type_code).and_return code
          end

          it "returns #{scenario}" do
            is_expected.to eql scenario
          end
        end
      end
    end
  end
end
