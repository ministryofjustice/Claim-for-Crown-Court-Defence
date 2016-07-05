module Stats
  class CompletionRateDataGenerator < BaseDataGenerator

    private

    def report_types
      {
        'completion_percentage' => 'Completion Rate'
      }
    end

    def transform_data_value(value)
      value / 100.0
    end

  end
end