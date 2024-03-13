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
        #{when_error_like('%Cannot create a bill of type%', 'BILL_TYPE#CREATION_ERROR')}
        #{when_error_like('%Bill Sub Type%not found in%', 'BILL_TYPE#NOT_FOUND_ERROR')}
        #{when_error_like('%Invalid scenario%for Bill Sub Type%', 'BILL_TYPE#INVALID_SCENARIO_ERROR')}
        #{when_error_like('%At least one Bill object MUST be included on a claim%', 'CLAIM#MISSING_BILL_ERROR')}
        #{when_error_like('%Offence object MUST not be NULL for a claim.%', 'CLAIM#MISSING_OFFENCE_ERROR')}
        #{when_error_like('%is a mandatory field%', 'CLAIM#MISSING_MANDATORY_FIELD_ERROR')}
        #{when_error_like('%Required field not entered%', 'CLAIM#MISSING_MANDATORY_FIELD_ERROR')}
        #{when_error_like('%A claim already exists for these case details%', 'CLAIM#ALREADY_EXISTS_ERROR')}
        #{when_error_like('%A case already exists for these case details%', 'CLAIM#ALREADY_EXISTS_ERROR')}
        #{when_error_like('%A claim with these details already exists in the system%', 'CLAIM#ALREADY_EXISTS_ERROR')}
        #{when_error_like('%Details of the entered case already exist in%', 'CLAIM#ALREADY_EXISTS_ERROR')}
        #{when_error_like('%First day of Trial%CANNOT come before Rep Order Date%', 'CLAIM#FIRST_DAY_TRIAL_VALIDATION_ERROR')}
        #{when_error_like('%Cannot calculate the fee%', 'FEE#CALCULATION_ERROR')}
        #{when_error_like('%Wasted Preparation Fee%', 'FEE#WASTED_PREPARATION_FEE_ERROR')}
        #{when_error_like('%No defendant found for Rep Order Number%', 'REP_ORDER#DEFENDANT_NOT_FOUND')}
        #{when_error_like('%Error retrieving defendant details for Rep Order Number%', 'REP_ORDER#DEFENDANT_DETAILS_NOT_FOUND')}
        #{when_error_like('%Expense Date Incurred%', 'EXPENSE#DATE_INCURRED_ERROR')}
        #{when_error_like('%The supplier account code%', 'SUPPLIER_NUMBER#INVALID_ERROR')}
        #{when_error_like('%Supplier Account Number cannot be empty%', 'SUPPLIER_NUMBER#CANNOT_BE_EMPTY_ERROR')}
        #{when_error_like('%VAT Amount % is too high for Net Amount supplied %', 'NET_AMOUNT#INVALID_VAT_AMOUNT_ERROR')}
        #{when_error_like('%Read timed out%', 'CONNECTION#TIMEOUT_ERROR')}
        #{when_error_like('%Failed: HTTP Error Code%', 'CONNECTION#HTTP_ERROR')}
        #{when_error_like('%Claim injection failed%', 'GENERIC_FAILED_INJECTION_ERROR')}
        #{when_error_like('%Unrecognized field%', 'PARSING#INVALID_FIELD_ERROR')}
        #{when_error_like('%Text%could not be parsed%', 'PARSING#PARSING_ERROR')}
        #{when_error_like('%The supplied JSON string is EMPTY%', 'PARSING#PARSING_ERROR')}
        #{when_error_like('%no protocol:%', 'INTERNAL_ERROR')}
        #{when_error_like('%A system exception has occurred%', 'INTERNAL_ERROR')}
        #{when_error_like('%An application error has occurred%', 'INTERNAL_ERROR')}
        #{when_error_like('%java.%', 'INTERNAL_ERROR')}
        #{when_no_error_description}
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

    def when_error_like(error_string, error_type)
      "WHEN obj->>'error' ILIKE '#{error_string}' THEN '#{error_type}'"
    end

    def when_no_error_description
      "WHEN ((obj->>'error' = '') IS NOT FALSE) OR (obj->>'error' = 'nil') " \
        "OR (obj->>'error' = 'null') THEN 'NO_ERROR_DESCRIPTION'"
    end

    def date_range_clause
      return unless start_date && end_date
      "ia.created_at BETWEEN '#{start_date.to_fs(:db)}' AND '#{end_date.to_fs(:db)}'"
    end
  end
end
