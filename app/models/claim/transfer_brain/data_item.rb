module Claim
  class TransferBrain
    class DataItem
      include ActiveModel::Model

      attr_reader :litigator_type, :elected_case, :transfer_stage, :conclusion, :valid
      attr_accessor :transfer_fee_full_name, :allocation_type, :bill_scenario, :ppe_required, :days_claimable,
                    :transfer_stage_id, :case_conclusion_id, :validity, :claim

      def litigator_type=(value)
        @litigator_type = value&.downcase
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
      alias case_conclusion= conclusion=

      def valid=(value)
        @validity = ActiveModel::Type::Boolean.new.cast(value)
        @valid = value
      end

      def ==(other)
        return false unless litigator_type == other.litigator_type
        return false unless equal_for_scheme_nine?(other)
        return false unless equal_for_scheme_ten?(other)
        return false unless transfer_stage_id == other.transfer_stage_id

        true
      end

      def fee_scheme_version
        @fee_scheme_version ||= claim&.fee_scheme&.version
      end

      private

      def equal_for_scheme_nine?(other)
        return true unless other.fee_scheme_version == 9
        return false unless elected_case == other.elected_case
        return false unless elected_case || conclusion == other.conclusion

        true
      end

      def equal_for_scheme_ten?(other)
        return true unless other.fee_scheme_version == 10
        return false if elected_case

        if other.elected_case
          return false unless scheme_ten_elected_case_equivalent
        else
          return false unless conclusion == other.conclusion
        end

        true
      end

      def scheme_ten_elected_case_equivalent
        (litigator_type == 'new' && conclusion&.include?('Cracked')) || litigator_type == 'original'
      end
    end
  end
end
