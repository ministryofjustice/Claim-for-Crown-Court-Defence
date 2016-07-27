module Stats
  class ClaimRedeterminationsDataGenerator < BaseDataGenerator

    private

    def report_types
      {
        'redeterminations_average' => 'Redeterminations (7 days moving average)',
        'claim_submissions_average' => 'Submissions (7 days moving average)'
      }
    end

  end
end