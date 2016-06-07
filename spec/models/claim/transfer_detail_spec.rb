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
    let(:detail) { build :transfer_detail }

    describe '#unpopulated?' do
      it 'returns true for an empty object' do
        detail = TransferDetail.new
        expect(detail).to be_unpopulated
      end

      it 'returns false if any fields are populated' do
        detail = TransferDetail.new(elected_case: false)
        expect(detail).not_to be_unpopulated
      end
    end

    describe '#errors?' do
      before(:each) { detail.claim = build(:transfer_claim) }

      it 'returns false if there are no errors relating to transfer_detail fields' do
        expect(detail.errors?).to be false
      end

      it 'returns true if any of the transfer detail fields are marked as in error on the claim' do
        detail.claim.errors[:litigator_type] << 'error'
        expect(detail.errors?).to be true
      end

      it 'reteurns false if claim is nil' do
        detail.claim = nil
        expect(detail.errors?).to be false
      end
    end

    describe '#allocation_type' do
      it 'should return Grad' do
        expect(detail.allocation_type).to eq 'Grad'
      end

      it 'should return Fixed' do
        detail = build(:transfer_detail, litigator_type: 'new', elected_case: true, transfer_stage_id: 10, case_conclusion_id: nil)
        expect(detail.allocation_type).to eq 'Fixed'
      end
    end
  end
end
