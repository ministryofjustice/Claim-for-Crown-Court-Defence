module Reports
  class InjectionErrors
    COLUMNS = %w[error_category total].freeze

    def self.call(options = {})
      new(options).call
    end

    attr_reader :start_date, :end_date

    def initialize(options = {})
      @start_date = options[:start_date]
      @end_date = options[:end_date]
    end

    def call
      InjectionAttempt.connection.execute(query).to_a
    end

    private

    def query
      %{SELECT error_category, sum(total) as total
      FROM (#{aggregrate_query}) AS subquery GROUP BY error_category}
    end

    def aggregrate_query
      %{SELECT
      CASE
        WHEN obj->>'error' ILIKE '%Cannot create a bill of type%' THEN 'BILL_TYPE#CREATION_ERROR'
        WHEN obj->>'error' ILIKE '%Bill Sub Type%not found in%' THEN 'BILL_TYPE#NOT_FOUND_ERROR'
        WHEN obj->>'error' ILIKE '%Invalid scenario%for Bill Sub Type%' THEN 'BILL_TYPE#INVALID_SCENARIO_ERROR'
        WHEN obj->>'error' ILIKE '%At least one Bill object MUST be included on a claim%' THEN 'CLAIM#MISSING_BILL_ERROR'
        WHEN obj->>'error' ILIKE '%Offence object MUST not be NULL for a claim.%' THEN 'CLAIM#MISSING_OFFENCE_ERROR'
        WHEN obj->>'error' ILIKE '%is a mandatory field%' THEN 'CLAIM#MISSING_MANDATORY_FIELD_ERROR'
        WHEN obj->>'error' ILIKE '%Required field not entered%' THEN 'CLAIM#MISSING_MANDATORY_FIELD_ERROR'
        WHEN obj->>'error' ILIKE '%A claim already exists for these case details%' THEN 'CLAIM#ALREADY_EXISTS_ERROR'
        WHEN obj->>'error' ILIKE '%A case already exists for these case details%' THEN 'CLAIM#ALREADY_EXISTS_ERROR'
        WHEN obj->>'error' ILIKE '%A claim with these details already exists in the system%' THEN 'CLAIM#ALREADY_EXISTS_ERROR'
        WHEN obj->>'error' ILIKE '%Details of the entered case already exist in%' THEN 'CLAIM#ALREADY_EXISTS_ERROR'
        WHEN obj->>'error' ILIKE '%First day of Trial%CANNOT come before Rep Order Date%' THEN 'CLAIM#FIRST_DAY_TRIAL_VALIDATION_ERROR'
        WHEN obj->>'error' ILIKE '%Cannot calculate the fee%' THEN 'FEE#CALCULATION_ERROR'
        WHEN obj->>'error' ILIKE '%Wasted Preparation Fee%' THEN 'FEE#WASTED_PREPARATION_FEE_ERROR'
        WHEN obj->>'error' ILIKE '%No defendant found for Rep Order Number%' THEN 'REP_ORDER#DEFENDANT_NOT_FOUND'
        WHEN obj->>'error' ILIKE '%Error retrieving defendant details for Rep Order Number%' THEN 'REP_ORDER#DEFENDANT_DETAILS_NOT_FOUND'
        WHEN obj->>'error' ILIKE '%Expense Date Incurred%' THEN 'EXPENSE#DATE_INCURRED_ERROR'
        WHEN obj->>'error' ILIKE '%The supplier account code%' THEN 'SUPPLIER_NUMBER#INVALID_ERROR'
        WHEN obj->>'error' ILIKE '%Supplier Account Number cannot be empty%' THEN 'SUPPLIER_NUMBER#CANNOT_BE_EMPTY_ERROR'
        WHEN obj->>'error' ILIKE '%VAT Amount % is too high for Net Amount supplied %' THEN 'NET_AMOUNT#INVALID_VAT_AMOUNT_ERROR'
        WHEN obj->>'error' ILIKE '%Read timed out%' THEN 'CONNECTION#TIMEOUT_ERROR'
        WHEN obj->>'error' ILIKE '%Failed: HTTP Error Code%' THEN 'CONNECTION#HTTP_ERROR'
        WHEN obj->>'error' ILIKE '%Claim injection failed%' THEN 'GENERIC_FAILED_INJECTION_ERROR'
        WHEN obj->>'error' ILIKE '%Unrecognized field%' THEN 'PARSING#INVALID_FIELD_ERROR'
        WHEN obj->>'error' ILIKE '%Text%could not be parsed%' THEN 'PARSING#PARSING_ERROR'
        WHEN obj->>'error' ILIKE '%The supplied JSON string is EMPTY%' THEN 'PARSING#PARSING_ERROR'
        WHEN obj->>'error' ILIKE '%no protocol:%' THEN 'INTERNAL_ERROR'
        WHEN obj->>'error' ILIKE '%A system exception has occurred%' THEN 'INTERNAL_ERROR'
        WHEN obj->>'error' ILIKE '%An application error has occurred%' THEN 'INTERNAL_ERROR'
        WHEN obj->>'error' ILIKE '%java.%' THEN 'INTERNAL_ERROR'
        WHEN ((obj->>'error' = '') IS NOT FALSE) OR (obj->>'error' = 'nil') OR (obj->>'error' = 'null') THEN 'NO_ERROR_DESCRIPTION'
        ELSE 'UNCATEGORIZED_ERROR'
      END as error_category,
      COUNT(*) as total
      FROM injection_attempts ia, json_array_elements(ia.error_messages->'errors') obj
      WHERE #{where_conditions}
      GROUP BY obj->>'error'}
    end

    def where_conditions
      ['ia.succeeded = false', date_range_clause].compact.join(' AND ')
    end

    def date_range_clause
      return unless start_date && end_date
      "ia.created_at BETWEEN '#{start_date.to_s(:db)}' AND '#{end_date.to_s(:db)}'"
    end
  end
end
