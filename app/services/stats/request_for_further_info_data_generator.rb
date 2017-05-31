module Stats
  class RequestForFurtherInfoDataGenerator < BaseDataGenerator
    private

    def report_types
      {
        'claims_authorised_after_info_requested' => 'requested',
        'claims_authorised_without_further_info' => 'not requested'
      }
    end
  end
end
