# frozen_string_literal: true

RSpec.describe Stats::ManagementInformation::Generator do
  subject(:generator) { described_class.new(options) }

  let(:options) { {} }
  let(:scheme_class) { Stats::ManagementInformation::Scheme }

  describe '#call' do
    subject(:result) { generator.call }

    it 'returns a Stats::Result object' do
      is_expected.to be_instance_of(Stats::Result)
    end

    it 'returns Stats::Result object with content' do
      expect(result.content).to be_truthy
    end

    context 'when filtering by scheme' do
      before do
        create(:advocate_final_claim, :submitted)
        create(:litigator_final_claim, :submitted)
      end

      let(:rows) { CSV.parse(result.content, headers: true) }

      context 'with no scheme' do
        let(:options) { {} }

        it { expect(rows['Scheme']).to match_array(%w[AGFS LGFS]) }
      end

      context 'with AGFS scheme' do
        let(:options) { { scheme: scheme } }
        let(:scheme) { scheme_class.new('agfs') }

        it { expect(rows['Scheme']).to match_array(%w[AGFS]) }
      end

      context 'with LGFS scheme' do
        let(:options) { { scheme: scheme } }
        let(:scheme) { scheme_class.new('lgfs') }

        it { expect(rows['Scheme']).to match_array(%w[LGFS]) }
      end
    end

    context 'with logging' do
      before { allow(LogStuff).to receive(:info) }

      it 'logs start and end' do
        generator.call
        expect(LogStuff).to have_received(:info).twice
      end
    end

    context 'when unexpected errors raised' do
      before do
        allow(CSV).to receive(:generate).and_raise(StandardError, 'oops')
        allow(LogStuff).to receive(:error)
      end

      it 'uses LogStuff to log error' do
        generator.call
      rescue StandardError
        nil
      ensure
        expect(LogStuff).to have_received(:error).once
      end

      it 're-raises the error' do
        expect { generator.call }.to raise_error(StandardError, 'oops')
      end
    end
  end
end
