module S3Headers
  extend ActiveSupport::Concern

  class_methods do
    def s3_headers
      {
        s3_headers: {
          'x-amz-meta-Cache-Control' => 'no-cache',
          'Expires' => 3.months.from_now.httpdate
        },
        s3_permissions: :private,
        s3_region: region
      }
    end

    private

    def region
      Settings.aws.region
    end
  end
end
