module RakeHelpers
  module SubmittedClaims
    def self.write(filename)
      truncate = Arel.sql("date_trunc('week', created_at)")

      end_date = Time.zone.now.monday
      start_date = end_date - 12.weeks

      CSV.open(filename, 'wb') do |csv|
        csv << ['Week starting', 'Submitted claims']
        ClaimStateTransition
          .where(ClaimStateTransition.arel_table[:created_at].between(start_date..end_date))
          .where(to: 'submitted')
          .group(truncate).count
          .sort_by { |row| row.first }.reverse
          .each { |row| csv << [row[0].strftime('%d/%m/%Y'), row[1]] }
      end
    end
  end
end