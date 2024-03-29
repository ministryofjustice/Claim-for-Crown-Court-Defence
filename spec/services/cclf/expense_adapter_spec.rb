require 'rails_helper'

RSpec.describe CCLF::ExpenseAdapter, type: :adapter do
  let(:expense) { instance_double(Expense) }

  # All expenses map to the TRAVEL COSTS disbursement bill sub-type in CCLF
  EXPENSE_BILL_TYPES = ['DISBURSEMENT', 'TRAVEL COSTS'].freeze
  EXPENSE_TYPES = %i[CAR PARK HOTEL TRAIN TRAVL ROAD CABF SUBS BIKE].freeze

  context 'bill mappings' do
    EXPENSE_TYPES.each do |unique_code|
      final_claim_bill_scenarios.each_key do |fee_type_code|
        context "when an expense of type #{unique_code} is attached to a claim with case of type #{fee_type_code}" do
          subject(:instance) { described_class.new(expense) }

          let(:claim) { instance_double(Claim::LitigatorClaim, case_type:) }
          let(:case_type) { instance_double(CaseType, fee_type_code:) }
          let(:expense_type) { instance_double(ExpenseType, unique_code:) }

          before do
            allow(expense).to receive_messages(claim:, expense_type:)
          end

          describe '#bill_type' do
            it 'returns DISBURSEMENT' do
              expect(instance.bill_type).to eql 'DISBURSEMENT'
            end
          end

          describe '#bill_subtype' do
            it 'returns TRAVEL COSTS' do
              expect(instance.bill_subtype).to eql 'TRAVEL COSTS'
            end
          end
        end
      end
    end
  end
end
