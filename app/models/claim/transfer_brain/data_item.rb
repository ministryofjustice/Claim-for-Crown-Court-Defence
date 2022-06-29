module Claim
  class TransferBrain
    class DataItem
      include ActiveModel::Model

      attr_reader :litigator_type, :elected_case, :transfer_stage, :conclusion, :valid
      attr_accessor :transfer_fee_full_name, :allocation_type, :bill_scenario, :ppe_required, :days_claimable,
                    :transfer_stage_id, :case_conclusion_id, :validity

      def to_h
        {
          litigator_type => {
            elected_case => {
              transfer_stage_id => {
                case_conclusion_id => {
                  validity:,
                  transfer_fee_full_name:,
                  allocation_type:,
                  bill_scenario:,
                  ppe_required:,
                  days_claimable:
                }
              }
            }
          }
        }
      end

      def litigator_type=(value)
        @litigator_type = value.downcase
      end

      def elected_case=(value)
        @elected_case = ActiveModel::Type::Boolean.new.cast(value)
      end

      def transfer_stage=(value)
        @transfer_stage_id = TransferBrain.transfer_stage_id(value)
        @transfer_stage = value
      end

      def conclusion=(value)
        @case_conclusion_id = value.blank? ? '*' : TransferBrain.case_conclusion_id(value)
        @conclusion = value
      end

      def valid=(value)
        @validity = ActiveModel::Type::Boolean.new.cast(value)
        @valid = value
      end
    end
  end
end
