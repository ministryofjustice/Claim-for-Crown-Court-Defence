require 'rails_helper'

describe 'LaaExpenseAdapter' do
  context 'AGFS' do

    let(:claim) { Claim::AdvocateClaim.new }
    let(:expense)  { Expense.new(claim: claim, expense_type: expense_type) }

    describe '.laa_bill_sub_type' do
      context 'Car travel' do
        let(:expense_type) { build :expense_type, :car_travel }

        it 'translates Car Travel / Court hearing to Travel & Hotel - Car / AGFS_THE_TRV_CR' do
          expense.reason_id = 1
          expect(expense.laa_bill_type_and_sub_type).to eq [ 'AGFS_EXPENSES', 'AGFS_THE_TRV_CR']
        end

        it 'transates Car Travel / View of crime scene to Conferences & Views - Car	/ AGFS_TCT_TRV_CR' do
          expense.reason_id = 4
          expect(expense.laa_bill_type_and_sub_type).to eq [ 'AGFS_EXPENSES', 'AGFS_TCT_TRV_CR' ]
        end
      end

      context 'Travel time' do
        let(:expense_type) { build :expense_type, :travel_time }

        it 'translates Travel time / Court Hearing into nil' do
          expense.reason_id = 1
          expect(expense.laa_bill_type_and_sub_type).to be_nil
        end

        it 'translates Travel time / Pre-trial conference defendant to Conferences & Views - Travel Time/ AGFS_TCT_CNF_VW' do
          expense.reason_id = 3
          expect(expense.laa_bill_type_and_sub_type).to eq [ 'AGFS_EXPENSES', 'AGFS_TCT_CNF_VW' ]
        end
      end
    end
  end
end
