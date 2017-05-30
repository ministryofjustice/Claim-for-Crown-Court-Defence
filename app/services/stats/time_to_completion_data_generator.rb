module Stats
  class TimeToCompletionDataGenerator < BaseDataGenerator
    private

    def report_types
      {
        'completion_time' => 'in days'
      }
    end

    def transform_data_value(value)
      # transform value on statistics table which is in seconds to days
      (value / 100.0).round(2)
    end
  end
end
