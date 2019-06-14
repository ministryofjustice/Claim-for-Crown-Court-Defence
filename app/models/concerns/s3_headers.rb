module S3Headers
  extend ActiveSupport::Concern

  module ClassMethods
    def s3_headers
      { s3_headers: {
        'x-amz-meta-Cache-Control' => 'no-cache',
        'Expires' => 3.months.from_now.httpdate
      },
        s3_permissions: :private,
        s3_region: Settings.aws.s3.region }
    end
  end
end
