module Stats
  class ClaimRedeterminationsDataGenerator < BaseDataGenerator

    private

    def report_types
      {
        'redeterminations_average' => '7 days moving average'
      }
    end

  end
end