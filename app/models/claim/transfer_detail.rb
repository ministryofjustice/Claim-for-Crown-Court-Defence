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

    belongs_to :claim, class_name: Claim::TransferClaim, foreign_key: :claim_id

    validates :claim, presence: { message: 'blank' }
    validates :litigator_type, presence: { message: 'blank' }
    validates :transfer_stage_id, presence: { message: 'blank' }
    validates :transfer_date, presence: { message: 'blank' }

    validates :litigator_type, inclusion: { in: %w[ original new ], message: 'not_in_list', allow_nil: true }
    validates :elected_case, inclusion: { in: [true, false], message: 'blank_or_invalid' }
    validates :transfer_stage_id, inclusion: { in: TransferBrain.transfer_stage_ids, message: 'not_in_list', allow_nil: true }

    validate :case_conclusion_validation

    def case_conclusion_validation
      if self.litigator_type == 'original'
        errors[:case_conclusion] << 'invalid_original' unless case_conclusion_id.blank?
      else
        if elected_case?
          errors[:case_conclusion] << 'invalid_new_elected' unless case_conclusion_id.blank?
        else
          errors[:case_conclusion] << 'invalid_new_non_elected' if case_conclusion_id.blank?
        end
      end
    end

  end
end
