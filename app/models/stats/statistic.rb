# == Schema Information
#
# Table name: statistics
#
#  id          :integer          not null, primary key
#  date        :date
#  report_name :string
#  claim_type  :string
#  value_1     :integer
#  value_2     :integer          default(0)
#

module Stats
  class Statistic < ApplicationRecord
    self.table_name = 'statistics'

    def self.find_by_date_and_report_name(date, report_name)
      Statistic.where(date: date, report_name: report_name).order(:claim_type)
    end

    def self.report(report_name, claim_type, start_date, end_date)
      Statistic.where(report_name: report_name, claim_type: claim_type)
               .where('date between ? and ?', start_date.to_date, end_date.to_date)
               .order(:date)
    end

    def self.create_or_update(date, report_name, claim_type, value1, value2 = 0)
      stat = Statistic.where(date: date, report_name: report_name, claim_type: claim_type).first
      if stat
        stat.update(value_1: value1, value_2: value2)
        retval = 0
      else
        Statistic.create(
          date: date,
          report_name: report_name,
          claim_type: claim_type,
          value_1: value1,
          value_2: value2
        )
        retval = 1
      end
      retval
    end
  end
end
