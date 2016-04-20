# == Schema Information
#
# Table name: transfer_details
#
#  id                 :integer          not null, primary key
#  claim_id           :integer
#  litigator_type     :string
#  elected_case       :boolean
#  transfer_stage_id  :integer
#  transfer_date      :date
#  case_conclusion_id :integer
#

require 'rails_helper'

module Claim

  describe TransferDetail do

    let(:detail)  { build :transfer_detail }

    context 'validations' do

      it { should validate_presence_of(:claim).with_message('blank') }
      it { should validate_presence_of(:litigator_type).with_message('blank') }
      it { should validate_presence_of(:transfer_stage_id).with_message('blank') }
      it { should validate_presence_of(:transfer_date).with_message('blank') }

      it { should validate_inclusion_of(:litigator_type).in_array( %w{ original new }) }
      it { should validate_inclusion_of(:transfer_stage_id).in_array( [ 10, 20, 30, 40, 50, 60 ]).with_message('not_in_list') }

      context 'case_conclusion_id' do
        context 'original litigator type' do
          it 'validates that the case_conclusion is absent' do
            detail.litigator_type = 'original'
            detail.case_conclusion_id = 10
            expect(detail).not_to be_valid
            expect(detail.errors[:case_conclusion]).to eq(['invalid_original'])
          end

          it 'allows blank conclusion id' do
            detail.litigator_type = 'original'
            detail.case_conclusion_id = nil
            expect(detail).to be_valid
          end
        end
      end

      context 'new litigator type' do
        context 'elected case true' do

          let(:detail)   { build :transfer_detail, litigator_type: 'new', elected_case: true }

          it 'validates that case conclusion is absent' do
            detail.case_conclusion_id = nil
            expect(detail).to be_valid
          end
          it 'throws error if present' do
            detail.case_conclusion_id = 10
            expect(detail).not_to be_valid
            expect(detail.errors[:case_conclusion]).to eq( [ 'invalid_new_elected'] )
          end
        end

        context 'elected case false' do
          let(:detail)   { build :transfer_detail, litigator_type: 'new', elected_case: false }

          it 'validates that case conclusion id is present' do
            detail.case_conclusion_id = 10
            expect(detail).to be_valid
          end
          it 'errors if absent' do
            detail.case_conclusion_id = nil
            expect(detail).not_to be_valid
            expect(detail.errors[:case_conclusion]).to eq (['invalid_new_non_elected'])
          end
        end

      end
    end

  end
end
