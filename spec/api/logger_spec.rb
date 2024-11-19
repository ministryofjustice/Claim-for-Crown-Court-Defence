RSpec.describe API::Logger do
  subject(:logger) { described_class.new(app) }

  # Placeholder object to allow Logger to initialise
  let(:app) { {} }

  before do
    logger.instance_variable_set(:@env, env)
  end

  shared_examples 'email validation' do |email_type|
    context 'when provided a valid email' do
      let(:env) { { 'rack.request.form_hash' => { email_type.to_s => 'advocate@example.com' } } }

      it 'is redacted' do
        expect(logger.send(email_type)).to eq('a******e@e*****e.com')
      end
    end

    context 'when provided no email' do
      let(:env) { {} }

      it 'returns nil' do
        expect(logger.send(email_type)).to be_nil
      end
    end

    context 'when provided an invalid email' do
      let(:env) { { 'rack.request.form_hash' => { email_type.to_s => 'notavalidemail' } } }

      it 'fails gracefully' do
        expect(logger.send(email_type)).to eq('Invalid email, cannot be redacted')
      end
    end
  end

  describe '#user_email' do
    include_examples 'email validation', :user_email
  end

  describe '#creator_email' do
    include_examples 'email validation', :creator_email
  end

  describe 'request log (#before)' do
    context 'when provided an empty set of data' do
      let(:empty_payload) do
        { request_id: nil,
          method: nil,
          path: nil,
          creator_email: nil,
          user_email: nil,
          claim_id: nil,
          case_number: nil,
          input_parameters: [] }
      end

      let(:env) { {} }

      before do
        allow(LogStuff).to receive(:send)
        logger.before
      end

      it 'returns nil in empty fields' do
        expect(LogStuff).to have_received(:send).with(:info,
                                                      type: 'api-request',
                                                      data: empty_payload)
      end
    end

    context 'when provided a valid set of data' do
      let(:payload) do
        { request_id: '123',
          method: 'GET',
          path: 'valid/path',
          creator_email: 'a******e@e*****e.com',
          user_email: 'a******e@e*****e.com',
          claim_id: '456',
          case_number: '789',
          input_parameters: %w[creator_email user_email claim_id case_number] }
      end

      let(:env) do
        { 'action_dispatch.request_id' => '123',
          'REQUEST_METHOD' => 'GET',
          'PATH_INFO' => 'valid/path',
          'rack.request.form_hash' => {
            'creator_email' => 'advocate@example.com',
            'user_email' => 'advocate@example.com',
            'claim_id' => '456',
            'case_number' => '789'
          } }
      end

      before do
        allow(LogStuff).to receive(:send)
        logger.before
      end

      it 'records the required fields and sends to LogStuff' do
        expect(LogStuff).to have_received(:send).with(:info,
                                                      type: 'api-request',
                                                      data: payload)
      end
    end
  end

  describe 'response log (#after)' do
    context 'when no status code is provided' do
      let(:env) { {} }

      before do
        allow(LogStuff).to receive(:send)
        logger.after
      end

      it 'does not submit anything to LogStuff' do
        expect(LogStuff).not_to have_received(:send)
      end
    end

    shared_examples 'valid response' do
      before do
        logger.instance_variable_set(:@app_response, [status, '', body])
        allow(LogStuff).to receive(:send)
        logger.after
      end

      context 'when invalid data is provided' do
        let(:env) { {} }
        let(:body) { 'invalid' }

        it 'fails gracefully and records an error' do
          expect(LogStuff).to have_received(:send)
            .once.with(:error,
                       type: 'api-response-body',
                       data: { request_id: nil },
                       error: "Error parsing API response body: \nJSON::ParserError - unexpected token at 'i'")
        end
      end

      context 'when no data is provided' do
        let(:env) { {} }
        let(:body) do
          [[{ empty: 'true' }].to_json] # There needs to be something in here or parsing will crash
        end
        let(:empty_payload) do
          { request_id: nil,
            path: nil,
            status:,
            claim_id: nil,
            case_number: nil,
            id: nil,
            creator_email: nil,
            input_parameters: [],
            user_email: nil }
        end

        it 'returns nil in empty fields' do
          expect(LogStuff).to have_received(:send).with(:info,
                                                        type: 'api-response',
                                                        data: empty_payload)
        end
      end

      context 'when valid data is provided' do
        let(:env) do
          { 'action_dispatch.request_id' => '123',
            'PATH_INFO' => 'api/valid/path' }
        end
        let(:body) do
          [[{ 'claim_id' => '456',
              'case_number' => '789',
              'id' => '1' }].to_json]
        end
        let(:payload) do
          { request_id: '123',
            path: 'api/valid/path',
            status:,
            claim_id: '456',
            case_number: '789',
            id: '1',
            creator_email: nil,
            input_parameters: [],
            user_email: nil }
        end

        it 'records the required fields and sends to LogStuff' do
          expect(LogStuff).to have_received(:send).with(:info,
                                                        type: 'api-response',
                                                        data: payload)
        end
      end
    end

    context 'when a 200 status code is provided' do
      let(:status) { 200 }

      include_examples 'valid response'
    end

    context 'when a 201 status code is provided' do
      let(:status) { 201 }

      include_examples 'valid response'
    end

    context 'when a non-200 status is provided' do
      before do
        logger.instance_variable_set(:@app_response, [400, '', body])
        allow(LogStuff).to receive(:send)
        logger.after
      end

      let(:env) do
        { 'action_dispatch.request_id' => '123',
          'PATH_INFO' => 'api/valid/path' }
      end
      let(:body) do
        [[{ 'error' => 'Test error' }].to_json]
      end

      it 'logs an error and records it' do
        expect(LogStuff).to have_received(:send).once.with(:error, type: 'api-error',
                                                                   data: hash_including(request_id: '123',
                                                                                        path: 'api/valid/path',
                                                                                        status: 400),
                                                                   error: 'Test error')
      end
    end
  end
end
