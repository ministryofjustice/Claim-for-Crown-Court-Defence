module Stats
  class SchemeTenReport
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :report_date

    validates_each :report_date do |record, attr, value|
      record.errors.add attr, 'must be in the past' if value.to_date >= Date.today
    end
  end
end
