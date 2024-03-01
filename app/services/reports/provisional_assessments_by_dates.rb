module Reports
  class ProvisionalAssessmentsByDates
    NAME = 'provisional_assessment'.freeze
    COLUMNS = %w[scheme provider_name provider_type supplier_number case_type offence_name offence_type ppe
                 number_of_trial_days date_submitted disbursements_claimed fees_claimed expenses_claimed total_claimed
                 disbursements_authorised fees_authorised expenses_authorised total_authorised total_percent_authorised
                 fees_percent_authorised expenses_percent_authorised disbursements_percent_authorised].freeze

    def self.call(options = {})
      new(options).call
    end

    attr_reader :start_date, :end_date

    def initialize(options = {})
      @start_date = options[:start_date]
      @end_date = options[:end_date]
    end

    def call
      Stats::MIData.connection.execute(query).to_a
    end

    private

    def query
      %{SELECT
        scheme_name AS scheme,
        provider_name,
        provider_type,
        supplier_number,
        case_type,
        offence_name,
        offence_type,
        ppe,
        actual_trial_length AS number_of_trial_days,
        last_submitted_at AS date_submitted,
        disbursements_total AS disbursements_claimed,
        fees_total AS fees_claimed,
        expenses_total AS expenses_claimed,
        amount_claimed AS total_claimed,
        assessment_disbursements AS disbursements_authorised,
        assessment_fees AS fees_authorised,
        assessment_expenses AS expenses_authorised,
        amount_authorised AS total_authorised,
        amount_authorised/NULLIF(amount_claimed, 0) as total_percent_authorised,
        assessment_fees /NULLIF(fees_total, 0) as fees_percent_authorised,
        assessment_disbursements /NULLIF(disbursements_total, 0) as expenses_percent_authorised,
        amount_authorised/NULLIF(amount_claimed, 0) as disbursements_percent_authorised
        FROM mi_data
        WHERE last_submitted_at BETWEEN '#{start_date.to_fs(:db)}' AND '#{end_date.to_fs(:db)}'}
    end
  end
end
