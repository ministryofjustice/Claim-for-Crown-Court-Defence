# frozen_string_literal: true

RSpec.describe Stats::ManagementInformation::DailyReportGenerator do
  subject(:generator) { described_class.new(**options) }

  let(:options) { {} }
  let(:expected_headers) do
    [
      'Id',
      'Scheme',
      'Case number',
      'Supplier number',
      'Organisation',
      'Case type name',
      'Bill type',
      'Claim total',
      'Submission type',
      'Transitioned at',
      'Last submitted at',
      'Originally submitted at',
      'Allocated at',
      'Completed at',
      'Current or end state',
      'State reason code',
      'Rejection reason',
      'Case worker',
      'Disk evidence case',
      'Main defendant',
      'Maat reference',
      'Rep order issued date',
      'AF1/LF1 processed by',
      'Misc fees'
    ]
  end

  describe '#call' do
    subject(:result) { generator.call }

    it 'returns a Stats::Result object' do
      is_expected.to be_instance_of(Stats::Result)
    end

    it 'returns Stats::Result object with content' do
      expect(result.content).to be_truthy
    end

    it 'csv has expected headers' do
      csv = CSV.parse(result.content, headers: true)
      expect(csv.headers).to match_array(expected_headers)
    end

    context 'with some data' do
      let!(:agfs_claim) { create(:advocate_final_claim, :submitted) }

      let!(:lgfs_claim) do
        create(:litigator_final_claim, :allocated, disk_evidence: true).tap do |claim|
          claim.tap do |c|
            assign_fees_and_expenses_for(c)
            c.authorise_part!({ author_id: create(:case_worker,
                                                  user: create(:user,
                                                               first_name: 'Case',
                                                               last_name: 'Worker-one')).user.id })
          end

          claim.redetermine!
          claim.allocate!
          claim.refuse!({ author_id: create(:case_worker,
                                            user: create(:user,
                                                         first_name: 'Case',
                                                         last_name: 'Worker-two')).user.id,
                          reason_code: ['reason'],
                          reason_text: 'reason text from caseworker' })
        end
      end

      let(:rows) { CSV.parse(result.content, headers: true) }

      it {
        expect(rows['Id'])
          .to match_array([agfs_claim.id.to_s, lgfs_claim.id.to_s, lgfs_claim.id.to_s])
      }

      it {
        expect(rows['Scheme'])
          .to match_array(%w[AGFS LGFS LGFS])
      }

      it {
        expect(rows['Case number'])
          .to match_array([agfs_claim.case_number, lgfs_claim.case_number, lgfs_claim.case_number])
      }

      it {
        expect(rows['Supplier number'])
          .to match_array([agfs_claim.supplier_number, lgfs_claim.supplier_number, lgfs_claim.supplier_number])
      }

      it {
        expect(rows['Organisation'])
          .to match_array([agfs_claim.creator.provider.name,
                           lgfs_claim.creator.provider.name,
                           lgfs_claim.creator.provider.name])
      }

      it {
        expect(rows['Case type name'])
          .to match_array([agfs_claim.case_type.name, lgfs_claim.case_type.name, lgfs_claim.case_type.name])
      }

      it {
        expect(rows['Bill type'])
          .to match_array(['AGFS Final', 'LGFS Final', 'LGFS Final'])
      }

      it {
        expect(rows['Claim total'])
          .to match_array([format('%.2f', agfs_claim.total + agfs_claim.vat_amount),
                           format('%.2f', lgfs_claim.total + lgfs_claim.vat_amount),
                           format('%.2f', lgfs_claim.total + lgfs_claim.vat_amount)])
      }

      it { expect(rows['Submission type']).to match_array(%w[new new redetermination]) }
      it { expect(rows['Transitioned at']).to all(match(%r{\d{2}/\d{2}/\d{4}})) }
      it { expect(rows['Last submitted at']).to all(match(%r{\d{2}/\d{2}/\d{4}})) }
      it { expect(rows['Originally submitted at']).to all(match(%r{\d{2}/\d{2}/\d{4}})) }
      it { expect(rows['Allocated at']).to all(match(%r{(\d{2}/\d{2}/\d{4}|n/a)})) }
      it { expect(rows['Completed at']).to all(match(%r{(\d{2}/\d{2}/\d{4} \d{2}:\d{2}|n/a)})) }
      it { expect(rows['Current or end state']).to match_array(%w[submitted part_authorised refused]) }
      it { expect(rows['State reason code']).to match_array([nil, nil, 'reason']) }
      it { expect(rows['Rejection reason']).to match_array([nil, nil, 'reason text from caseworker']) }

      it {
        expect(rows['Case worker'])
          .to match_array(['n/a',
                           'Case Worker-one',
                           'Case Worker-two'])
      }

      it { expect(rows['Disk evidence case']).to match_array(%w[No Yes Yes]) }

      it {
        expect(rows['Main defendant'])
          .to match_array([agfs_claim.defendants.first.name,
                           lgfs_claim.defendants.first.name,
                           lgfs_claim.defendants.first.name])
      }

      it {
        expect(rows['Maat reference'])
          .to match_array([agfs_claim.earliest_representation_order.maat_reference,
                           lgfs_claim.earliest_representation_order.maat_reference,
                           lgfs_claim.earliest_representation_order.maat_reference])
      }

      it {
        expect(rows['Rep order issued date'])
          .to match_array([agfs_claim.earliest_representation_order_date.strftime('%d/%m/%Y'),
                           lgfs_claim.earliest_representation_order_date.strftime('%d/%m/%Y'),
                           lgfs_claim.earliest_representation_order_date.strftime('%d/%m/%Y')])
      }

      it { expect(rows['AF1/LF1 processed by']).to match_array([nil, nil, 'Case Worker-one']) }

      it {
        expect(rows['Misc fees'])
          .to match_array([agfs_claim.misc_fees.map { |f| f.fee_type.description }.join(' '),
                           lgfs_claim.misc_fees.map { |f| f.fee_type.description }.join(' '),
                           lgfs_claim.misc_fees.map { |f| f.fee_type.description }.join(' ')])
      }
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
