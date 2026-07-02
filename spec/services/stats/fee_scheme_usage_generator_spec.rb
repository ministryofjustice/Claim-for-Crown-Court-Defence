require 'rails_helper'

RSpec.describe Stats::FeeSchemeUsageGenerator do
  let(:expected_headers) do
    [
      'Month',
      'Fee scheme',
      'Total number of claims',
      'Total value of claims',
      'Most recent claim',
      'Advocate claim',
      'Advocate hardship claim',
      'Advocate interim claim',
      'Advocate supplementary claim',
      'Interim claim',
      'Litigator claim',
      'Litigator hardship claim',
      'Transfer claim',
      'Appeal against conviction',
      'Appeal against sentence',
      'Breach of crown court order',
      'Committal for sentence',
      'Contempt',
      'Cracked trial',
      'Cracked before retrial',
      'Discontinuance',
      'Elected cases not proceeded',
      'Guilty plea',
      'Hearing subsequent to sentence',
      'Retrial',
      'Trial'
    ]
  end

  describe '#call' do
    subject(:call) { described_class.new.call }

    let(:csv) { CSV.parse(call.content, headers: true) }
    let(:fee_schemes) { ['AGFS 1', 'LGFS 1'] }
    let(:case_type_names) do
      [
        'Appeal against conviction',
        'Appeal against sentence',
        'Breach of crown court order',
        'Committal for sentence',
        'Contempt',
        'Cracked trial',
        'Cracked before retrial',
        'Discontinuance',
        'Elected cases not proceeded',
        'Guilty plea',
        'Hearing subsequent to sentence',
        'Retrial',
        'Trial'
      ]
    end

    def find_row(month, scheme)
      csv.find { |row| row['Month'] == month && row['Fee scheme'] == scheme }
    end

    before do
      fee_scheme_records = fee_schemes.map do |name|
        fs_name, fs_version = name.split
        instance_double(FeeScheme, name: fs_name, version: fs_version.to_i)
      end

      fee_scheme_relation = instance_double(ActiveRecord::Relation)
      allow(FeeScheme).to receive(:where).with(name: %w[AGFS LGFS]).and_return(fee_scheme_relation)
      allow(fee_scheme_relation).to receive(:order).with(:name, :version).and_return(fee_scheme_records)

      allow(CaseType).to receive(:all).and_return(
        case_type_names.map { |name| instance_double(CaseType, name:) }
      )
    end

    def build_claim_double(data)
      fee_scheme = instance_double(FeeScheme, name: data[:scheme_name], version: data[:scheme_version])

      instance_double(Claim::BaseClaim,
                      fee_scheme:,
                      type: data[:type],
                      case_type_id: data[:case_type_id],
                      total: data[:total] || 0,
                      vat_amount: data[:vat_amount] || 0,
                      last_submitted_at: data[:submitted_at])
    end

    def stub_case_type_lookup(claims_data)
      names_by_id = claims_data.each_with_object({}) do |data, map|
        map[data[:case_type_id]] = data[:case_type_name] if data[:case_type_id]
      end
      allow(CaseType).to receive(:find) { |id| instance_double(CaseType, name: names_by_id.fetch(id)) }
    end

    def stub_claims(claims_data)
      stub_case_type_lookup(claims_data)
      stub_claim_query(claims_data.map { |data| build_claim_double(data) })
    end

    def stub_claim_query(claims)
      relation = instance_double(ActiveRecord::Relation)
      allow(Claim::BaseClaim).to receive_messages(active: Claim::BaseClaim, non_draft: relation)
      allow(relation).to receive(:where) { |args| stub_find_each(claims, args.fetch(:last_submitted_at)) }
    end

    def stub_find_each(claims, range)
      matched = claims.select { |claim| range.cover?(claim.last_submitted_at) }
      instance_double(ActiveRecord::Relation).tap do |filtered|
        allow(filtered).to receive(:find_each) { |&block| matched.each(&block) }
      end
    end

    context 'with claims in the current month' do
      let(:submitted_at) { Time.current }

      before do
        stub_claims([
                      { scheme_name: 'AGFS', scheme_version: 1, type: 'Claim::AdvocateClaim',
                        case_type_id: 1, case_type_name: 'Trial', total: 100.0, vat_amount: 20.0,
                        submitted_at: },
                      { scheme_name: 'AGFS', scheme_version: 1, type: 'Claim::AdvocateClaim',
                        case_type_id: 2, case_type_name: 'Guilty plea', total: 200.0, vat_amount: 40.0,
                        submitted_at: },
                      { scheme_name: 'LGFS', scheme_version: 1, type: 'Claim::LitigatorClaim',
                        case_type_id: 1, case_type_name: 'Trial', total: 50.0, vat_amount: 10.0,
                        submitted_at: }
                    ])
      end

      it 'has expected headers' do
        expect(csv.headers).to eq(expected_headers)
      end

      it 'returns rows containing the correct fee schemes' do
        expect(csv['Fee scheme'].uniq.compact).to eq(fee_schemes)
      end

      it 'returns the correct total claims for AGFS 1' do
        expect(find_row(Time.zone.today.strftime('%B'), 'AGFS 1')['Total number of claims']).to eq('2')
      end

      it 'returns the correct total value for AGFS 1' do
        expect(find_row(Time.zone.today.strftime('%B'), 'AGFS 1')['Total value of claims']).to eq('360.0')
      end

      it 'returns the correct claim type count for AGFS 1' do
        expect(find_row(Time.zone.today.strftime('%B'), 'AGFS 1')['Advocate claim']).to eq('2')
      end

      it 'returns the correct case type count for AGFS 1 Trial' do
        expect(find_row(Time.zone.today.strftime('%B'), 'AGFS 1')['Trial']).to eq('1')
      end

      it 'returns the correct case type count for AGFS 1 Guilty plea' do
        expect(find_row(Time.zone.today.strftime('%B'), 'AGFS 1')['Guilty plea']).to eq('1')
      end

      it 'returns the correct total claims for LGFS 1' do
        expect(find_row(Time.zone.today.strftime('%B'), 'LGFS 1')['Total number of claims']).to eq('1')
      end

      it 'returns zeroed claim types for LGFS 1 advocate claims' do
        expect(find_row(Time.zone.today.strftime('%B'), 'LGFS 1')['Advocate claim']).to eq('0')
      end
    end

    context 'with claims across multiple months' do
      before do
        stub_claims([
                      { scheme_name: 'AGFS', scheme_version: 1, type: 'Claim::AdvocateClaim',
                        case_type_id: 1, case_type_name: 'Trial', total: 100.0, vat_amount: 0.0,
                        submitted_at: 4.months.ago },
                      { scheme_name: 'LGFS', scheme_version: 1, type: 'Claim::TransferClaim',
                        case_type_id: nil, case_type_name: nil, total: 75.0, vat_amount: 0.0,
                        submitted_at: 5.months.ago }
                    ])
      end

      it 'correctly populates the LGFS 1 row 5 months ago' do
        expect(find_row(5.months.ago.strftime('%B'), 'LGFS 1')['Total number of claims']).to eq('1')
      end

      it 'correctly populates the AGFS 1 row 4 months ago' do
        expect(find_row(4.months.ago.strftime('%B'), 'AGFS 1')['Total number of claims']).to eq('1')
      end

      it 'has zero for AGFS 1 in months with no claims' do
        expect(find_row(5.months.ago.strftime('%B'), 'AGFS 1')['Total number of claims']).to eq('0')
      end
    end

    context 'with a claim submitted before the reporting window' do
      before do
        stub_claims([
                      { scheme_name: 'AGFS', scheme_version: 1, type: 'Claim::AdvocateClaim',
                        case_type_id: 1, case_type_name: 'Trial', total: 100.0, vat_amount: 20.0,
                        submitted_at: 7.months.ago }
                    ])
      end

      it 'excludes the claim from every month in the report' do
        expect(csv['Total number of claims'].compact.sum(&:to_i)).to eq(0)
      end
    end
  end

  context 'when logging without errors' do
    before do
      allow(LogStuff).to receive(:info)
      fee_scheme_relation = instance_double(ActiveRecord::Relation, order: [])
      allow(FeeScheme).to receive(:where).and_return(fee_scheme_relation)
      allow(CaseType).to receive(:all).and_return([])
      relation = instance_double(ActiveRecord::Relation)
      allow(Claim::BaseClaim).to receive_messages(active: Claim::BaseClaim, non_draft: relation)
      allow(relation).to receive(:where).and_return(instance_double(ActiveRecord::Relation, find_each: nil))
    end

    it 'log start and end' do
      described_class.call
      expect(LogStuff).to have_received(:info).twice
    end
  end

  context 'when logging errors' do
    before do
      allow(CSV).to receive(:generate).and_raise(StandardError)
      allow(LogStuff).to receive(:error)
    end

    it 'uses LogStuff to log error' do
      described_class.call
      expect(LogStuff).to have_received(:error).once
    end
  end
end
