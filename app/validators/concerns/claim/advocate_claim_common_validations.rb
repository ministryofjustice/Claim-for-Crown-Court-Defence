module Claim
  module AdvocateClaimCommonValidations
    extend ActiveSupport::Concern

    included do
      private

      def validate_creator
        super if defined?(super)
        validate_has_role(@record.creator.try(:provider),
                          :agfs,
                          :creator,
                          'must be from a provider with permission to submit AGFS claims')
      end

      def validate_advocate_category
        validate_presence(:advocate_category, 'blank')
        return if @record.advocate_category.blank?
        validate_inclusion(
          :advocate_category,
          @record.eligible_advocate_categories,
          I18n.t('validators.advocate.category')
        )
      end

      def validate_case_concluded_at
        validate_absence(:case_concluded_at, 'present')
      end

      def supplier_number_regex
        ExternalUser::SUPPLIER_NUMBER_REGEX
      end

      def validate_supplier_number
        validate_pattern(:supplier_number, supplier_number_regex, 'invalid')
      end
    end
  end
end
