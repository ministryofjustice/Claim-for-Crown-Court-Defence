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
  class TransferDetail < ActiveRecord::Base
    belongs_to :claim, class_name: Claim::TransferClaim, foreign_key: :claim_id, inverse_of: :transfer_detail

    acts_as_gov_uk_date :transfer_date

    def unpopulated?
      self.litigator_type.nil? && self.elected_case.nil? && self.transfer_stage_id.nil? && self.transfer_date.nil? && self.case_conclusion_id.nil?
    end

    def allocation_type
      TransferBrain.allocation_type(self)
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
