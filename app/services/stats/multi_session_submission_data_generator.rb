module Stats
  class MultiSessionSubmissionDataGenerator < BaseDataGenerator

    private

    def report_types
      {
        'multi_session_submissions' => 'Multi-session submissions',
        'single_session_submissions' => 'Single-session submissions'
      }
    end

  end
end