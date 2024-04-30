RSpec.describe API::Logger do
  subject(:logger) { described_class.new(app) }

  let(:app) { ->(_) { [200, { 'Content-Type' => 'text/plain' }, ['OK']] } }

  shared_examples 'email validation' do |email_type|
    context 'when provided a valid email' do
      it 'is redacted' do
        allow(logger).to receive(:request_data)
          .and_return({ email_type.to_s => 'advocate@example.com' })
        expect(logger.send(email_type)).to eq('a******e@e*****e.com')
      end
    end

    context 'when provided no email' do
      it 'returns nil' do
        allow(logger).to receive(:request_data)
          .and_return({})
        expect(logger.send(email_type)).to be_nil
      end
    end

    context 'when provided an invalid email' do
      it 'fails gracefully' do
        allow(logger).to receive(:request_data)
          .and_return({ email_type.to_s => 'notavalidemail' })
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

end
