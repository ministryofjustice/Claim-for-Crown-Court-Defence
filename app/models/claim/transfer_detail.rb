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

module Claim
  class TransferDetail < ApplicationRecord
    include Claim::TransferBrain::Delegatable

    belongs_to :claim, class_name: 'Claim::TransferClaim', inverse_of: :transfer_detail
    transfer_brain_delegate :allocation_type, :bill_scenario, :transfer_stage, :case_conclusion, :ppe_required,
                            :days_claimable

    def unpopulated?
      [litigator_type, elected_case, transfer_stage_id, transfer_date, case_conclusion_id].all?(&:nil?)
    end

    def ppe_required?
      ppe_required.eql?('TRUE')
    end

    def days_claimable?
      days_claimable.eql?('TRUE')
    end

    # returns true if there are any errors on the claim relating to transfer detail fields
    def errors?
      return false if claim.nil?
      claim.errors[:litigator_type].any? ||
        claim.errors[:elected_case].any? ||
        claim.errors[:transfer_stage_id].any? ||
        claim.errors[:transfer_date].any? ||
        claim.errors[:case_conclusion_id].any?
    end
  end
end
