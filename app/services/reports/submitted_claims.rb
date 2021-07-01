module Reports
  class SubmittedClaims
    NAME = 'submitted_claims'.freeze
    COLUMNS = ['Week starting', 'Submitted claims'].freeze
    SUBMISSION_DATE_WEEK = Arel.sql("date_trunc('week', original_submission_date::date)").freeze

    def self.call
      new.call
    end

    def call
      end_date = Time.zone.now.monday
      start_date = end_date - 12.weeks

      Claim::BaseClaim
        .where(original_submission_date: start_date..end_date)
        .group(SUBMISSION_DATE_WEEK).order(SUBMISSION_DATE_WEEK).count
        .transform_keys { |key| key.strftime('%d/%m/%Y') }
        .to_a
    end
  end
end
