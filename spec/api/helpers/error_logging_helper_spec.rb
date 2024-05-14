class ErrorLogger
  attr_accessor :env
end

RSpec.describe API::Helpers::ErrorLoggingHelper do
  describe '#log_error' do
    before do
      logger = ErrorLogger.new
      logger.extend(described_class)
      logger.env = { 'action_dispatch.request_id' => '123' }

      allow(LogStuff).to receive(:send)

      logger.log_error(400, error)
    end

    context 'with AuthorisationError' do
      let(:error) { API::Helpers::Authorisation::AuthorisationError.new('Unauthorised') }

      it 'logs the error' do
        expect(LogStuff).to have_received(:send)
          .with(:error,
                { error: 'API::Helpers::Authorisation::AuthorisationError - Unauthorised',
                  request_id: '123', status: 400, type: 'api-error' })
      end
    end

    context 'with ArgumentError' do
      let(:error) { ArgumentError.new('Error') }

      it 'logs the error' do
        expect(LogStuff).to have_received(:send)
          .with(:error,
                { error: 'ArgumentError - Error',
                  request_id: '123', status: 400, type: 'api-error' })
      end
    end
  end
end
