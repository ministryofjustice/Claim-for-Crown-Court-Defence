module Fee
  class MiscFeeValidator < Fee::BaseFeeValidator
    include Concerns::CaseNumbersValidator

    def self.fields
      %i[
        quantity
        rate
        case_numbers
      ] + super
    end

    private

    def validate_fee_type
      if run_base_fee_validators?
        super
      else
        validate_presence(:fee_type, :blank)
        validate_lgfs_fee_type_rules
      end
    end

    def validate_lgfs_fee_type_rules
      rule_sets = Fee::LGFS::FeeTypeRules.where(unique_code: @record.fee_type&.unique_code)
      Rule::Validator.new(@record, rule_sets).validate if rule_sets.present?
    end

    def validate_quantity
      super if run_base_fee_validators?
    end

    def validate_rate
      super if run_base_fee_validators?
    end

    def validate_amount
      if run_base_fee_validators? || fee_code.nil?
        super
      elsif @record.fee_type.unique_code.eql?('MIEVI')
        validate_evidence_provision_fee
      else
        validate_presence_and_numericality_govuk_formbuilder(:amount, minimum: 0.1)
      end
    end

    def run_base_fee_validators?
      !@record&.claim&.lgfs?
    end

    def validate_evidence_provision_fee
      valid_values = [45, 90]
      return if valid_values.include?(@record.amount.to_d)
      add_error(:amount, :incorrect_epf)
    end
  end
end
