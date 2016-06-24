# == Schema Information
#
# Table name: statistics
#
#  id          :integer          not null, primary key
#  date        :date
#  report_name :string
#  claim_type  :string
#  value_1     :integer
#

module Stats
  class Statistic < ActiveRecord::Base

    self.table_name = 'statistics'

    def self.find_by_date_and_report_name(date, report_name)
      Statistic.where(date: date, report_name: report_name).order(:claim_type)
    end

    def self.create_or_update(date, report_name, claim_type, value)
      stat = Statistic.where(date: date, report_name: report_name, claim_type: claim_type).first
      if stat
        stat.update(value_1: value)
        retval = 0
      else
        stat = Statistic.create(
          date: date,
          report_name: report_name,
          claim_type: claim_type,
          value_1: value
        )
        retval = 1
      end
      retval
    end
  end
end
