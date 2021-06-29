module RakeHelpers
  module SubmittedClaims
    def self.write(filename)
      truncate = Arel.sql("date_trunc('week', original_submission_date::date)")

      end_date = Time.zone.now.monday
      start_date = end_date - 12.weeks

      CSV.open(filename, 'wb') do |csv|
        csv << ['Week starting', 'Submitted claims']
        claims = Claim::BaseClaim
          .where(original_submission_date: start_date..end_date)
          .group(truncate).order(truncate).count
          .transform_keys { |key| key.strftime('%d/%m/%Y') }
          .to_a.each { |row| csv << row }
      end
    end
  end
end
