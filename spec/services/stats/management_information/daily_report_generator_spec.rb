# frozen_string_literal: true

RSpec.describe Stats::ManagementInformation::DailyReportGenerator do
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

    xit 'has expected headers' do
    end

    context 'with some data' do
      let!(:agfs_claim) { create(:advocate_final_claim, :submitted) }
      let!(:lgfs_claim) { create(:litigator_final_claim, :authorised) }

      let(:rows) { CSV.parse(result.content, headers: true) }

      it { expect(rows['Id']).to match_array([agfs_claim.id.to_s, lgfs_claim.id.to_s]) }
      it { expect(rows['Scheme']).to match_array(%w[AGFS LGFS]) }
      it { expect(rows['Case number']).to match_array([agfs_claim.case_number, lgfs_claim.case_number]) }
      it { expect(rows['Supplier number']).to match_array([agfs_claim.supplier_number, lgfs_claim.supplier_number]) }

      it {
        expect(rows['Organisation'])
          .to match_array([agfs_claim.creator.provider.name,
                           lgfs_claim.creator.provider.name])
      }

      it { expect(rows['Case type name']).to match_array([agfs_claim.case_type.name, lgfs_claim.case_type.name]) }
      it { expect(rows['Bill type']).to match_array(['AGFS Final', 'LGFS Final']) }

      it {
        expect(rows['Claim total'])
          .to match_array([(agfs_claim.total + agfs_claim.vat_amount).to_s,
                           (lgfs_claim.total + lgfs_claim.vat_amount).to_s])
      }

      it { expect(rows['Submission type']).to all(be == 'new') }
      it { expect(rows['Transitioned at']).to all(match(%r{\d{2}/\d{2}/\d{4}})) }
      it { expect(rows['Last submitted at']).to all(match(%r{\d{2}/\d{2}/\d{4}})) }
      it { expect(rows['Originally submitted at']).to all(match(%r{\d{2}/\d{2}/\d{4}})) }
      it { expect(rows['Allocated at']).to all(match(%r{(\d{2}/\d{2}/\d{4}|n/a)})) }
      it { expect(rows['Completed at']).to all(match(%r{(\d{2}/\d{2}/\d{4} \d{2}:\d{2}|n/a)})) }
      it { expect(rows['Current or end state']).to match_array(%w[submitted authorised]) }
      it { expect(rows['State reason code']).to all(be_nil) }
      it { expect(rows['Rejection reason']).to all(be_nil) }

      it {
        expect(rows['Case worker'])
          .to match_array(['n/a',
                           lgfs_claim.claim_state_transitions.find_by(to: 'authorised').author.name])
      }

      it { expect(rows['Disk evidence case']).to match_array(%w[No No]) }

      xit 'with a multiple journey claim' do
      end
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
        let(:options) { { scheme: :agfs } }

        it { expect(rows['Scheme']).to match_array(%w[AGFS]) }
      end

      context 'with LGFS scheme' do
        let(:options) { { scheme: :lgfs } }

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
