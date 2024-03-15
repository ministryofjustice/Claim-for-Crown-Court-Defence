module Reports
  class AdditionalTravelExpenseInformationByDates
    NAME = 'additional_travel_expense_information'.freeze
    COLUMNS = %w[claim_id travel_expense_additional_information].freeze

    def self.call(options = {})
      new(options).call
    end

    attr_reader :start_date, :end_date

    def initialize(options = {})
      @start_date = options[:start_date]
      @end_date = options[:end_date]
    end

    def call
      Expense.connection.execute(query).to_a
    end

    private

    def query
      <<~SQL
        SELECT
        DISTINCT(c.id) AS claim_id,
        c.travel_expense_additional_information
        FROM expenses e
        INNER JOIN claims c ON c.id = e.claim_id
        WHERE c.original_submission_date BETWEEN '#{start_date.to_fs(:db)}' AND '#{end_date.to_fs(:db)}'
        AND (calculated_distance IS NOT NULL
        AND LENGTH(c.travel_expense_additional_information)>0)
      SQL
    end
  end
end
