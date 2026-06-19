require 'json'
require 'securerandom'

module OmniAuth
  module Strategies
    class EntraMock
      include OmniAuth::Strategy

      option :name, 'entra_mock'

      def request_phase
        redirect callback_path
      end

      def callback_phase
        return fail!('entra_mock_http_error') unless mock_http_success?

        data = mock_data
        env['omniauth.auth'] = OmniAuth::AuthHash.new(
          provider: name,
          uid: data['uid'] || data['oid'] || SecureRandom.uuid,
          info: {
            email: data['email'],
            first_name: data['first_name'],
            last_name: data['last_name']
          },
          extra: {
            raw_info: data
          }
        )
        call_app!
      rescue StandardError => e
        fail!('entra_mock_error', e)
      end

      private

      def mock_data
        json = ENV.fetch('ENTRA_MOCK_JSON', nil)
        return default_data if json.nil? || json.strip.empty?

        JSON.parse(json)
      rescue JSON::ParserError
        default_data
      end

      def default_data
        {
          'uid' => 'mock-entra-uid',
          'email' => 'caseworker@example.com',
          'first_name' => 'Mock',
          'last_name' => 'Caseworker',
          'persona' => 'CaseWorker',
          'roles' => ['case_worker'],
          'location' => 'Mock Location'
        }
      end

      def mock_http_success?
        status = ENV.fetch('ENTRA_MOCK_HTTP_STATUS', nil)
        return true if status.nil? || status.strip.empty?

        status.to_i == 200
      end
    end
  end
end
