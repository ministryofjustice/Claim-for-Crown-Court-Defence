require 'rails_helper'

RSpec.describe Stats::Graphs::SixMonthPeriod do
  subject(:graph_data) { described_class.new }

  describe '#call' do
    subject(:result) { graph_data.call }

    let(:mon_name) do
      output = []
      6.times do |offset|
        month = (Time.current.end_of_month - offset.month).strftime('%b')
        output << month
      end
      output.reverse
    end

    let(:fee_schemes) { ['AGFS 1', 'AGFS 2', 'LGFS 1', 'LGFS 2'] }

    before do
      fee_scheme_records = fee_schemes.map do |name|
        fs_name, fs_version = name.split
        instance_double(FeeScheme, name: fs_name, version: fs_version.to_i)
      end

      fee_scheme_relation = instance_double(ActiveRecord::Relation)
      allow(FeeScheme).to receive(:where).with(name: %w[AGFS LGFS]).and_return(fee_scheme_relation)
      allow(fee_scheme_relation).to receive(:order).with(:name, :version).and_return(fee_scheme_records)
    end

    def build_claim_doubles(claims_data)
      claims_data.map do |data|
        fee_scheme = instance_double(FeeScheme, name: data[:scheme_name], version: data[:scheme_version])
        instance_double(Claim::BaseClaim, fee_scheme:, last_submitted_at: data[:submitted_at])
      end
    end

    def stub_claims(claims_data)
      stub_claim_query(build_claim_doubles(claims_data))
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

    def month_counts(counts = {})
      mon_name.each_with_index.to_h { |m, i| [m, counts.fetch(i, 0)] }
    end

    context 'when there are only agfs claims' do
      let(:expected) do
        [
          { name: 'AGFS 1', data: month_counts(0 => 2) },
          { name: 'AGFS 2', data: month_counts(1 => 2) },
          { name: 'LGFS 1', data: month_counts(0 => 0) },
          { name: 'LGFS 2', data: month_counts(0 => 0) }
        ]
      end

      before do
        stub_claims([
                      { scheme_name: 'AGFS', scheme_version: 1, submitted_at: 5.months.ago },
                      { scheme_name: 'AGFS', scheme_version: 1, submitted_at: 5.months.ago },
                      { scheme_name: 'AGFS', scheme_version: 2, submitted_at: 4.months.ago },
                      { scheme_name: 'AGFS', scheme_version: 2, submitted_at: 4.months.ago }
                    ])
      end

      it { is_expected.to eq(expected) }
    end

    context 'when there are only lgfs claims' do
      let(:expected) do
        [
          { name: 'AGFS 1', data: month_counts(0 => 0) },
          { name: 'AGFS 2', data: month_counts(0 => 0) },
          { name: 'LGFS 1', data: month_counts(0 => 2) },
          { name: 'LGFS 2', data: month_counts(1 => 2) }
        ]
      end

      before do
        stub_claims([
                      { scheme_name: 'LGFS', scheme_version: 1, submitted_at: 5.months.ago },
                      { scheme_name: 'LGFS', scheme_version: 1, submitted_at: 5.months.ago },
                      { scheme_name: 'LGFS', scheme_version: 2, submitted_at: 4.months.ago },
                      { scheme_name: 'LGFS', scheme_version: 2, submitted_at: 4.months.ago }
                    ])
      end

      it { is_expected.to eq(expected) }
    end

    context 'when there are both agfs and lgfs claims' do
      let(:expected) do
        [
          { name: 'AGFS 1', data: month_counts(0 => 1) },
          { name: 'AGFS 2', data: month_counts(2 => 1) },
          { name: 'LGFS 1', data: month_counts(0 => 2) },
          { name: 'LGFS 2', data: month_counts(5 => 1) }
        ]
      end

      before do
        stub_claims([
                      { scheme_name: 'AGFS', scheme_version: 1, submitted_at: 5.months.ago },
                      { scheme_name: 'LGFS', scheme_version: 1, submitted_at: 5.months.ago },
                      { scheme_name: 'LGFS', scheme_version: 1, submitted_at: 5.months.ago },
                      { scheme_name: 'AGFS', scheme_version: 2, submitted_at: 3.months.ago },
                      { scheme_name: 'LGFS', scheme_version: 2, submitted_at: Time.current }
                    ])
      end

      it { is_expected.to eq(expected) }
    end

    context 'when a claim is submitted before the six month window' do
      let(:expected) do
        [
          { name: 'AGFS 1', data: month_counts },
          { name: 'AGFS 2', data: month_counts },
          { name: 'LGFS 1', data: month_counts },
          { name: 'LGFS 2', data: month_counts }
        ]
      end

      before do
        stub_claims([
                      { scheme_name: 'AGFS', scheme_version: 1, submitted_at: 8.months.ago }
                    ])
      end

      it { is_expected.to eq(expected) }
    end
  end

  describe '#title' do
    subject(:graph_title) { graph_data.title }

    before { travel_to(Time.zone.parse('2023-10-10')) }

    it { is_expected.to eq('May - October') }
  end
end
