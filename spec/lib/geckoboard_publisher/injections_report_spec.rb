require 'rails_helper'

RSpec.describe GeckoboardPublisher::InjectionsReport, geckoboard: true do
  it_behaves_like 'geckoboard publishable report'

  # NOTE: calls to api.geckoboard.com are stubbed in rails_helper in case future reports are generated

  describe '#fields' do
    subject { described_class.new.fields.map { |field| [field.class, field.id, field.name] } }

    let(:expected_fields) do
      [
        Geckoboard::DateField.new(:date, name: 'Date'),
        Geckoboard::NumberField.new(:total_ccr_succeeded, name: 'Total CCR'),
        Geckoboard::NumberField.new(:total_ccr, name: 'Total number of CCR injections'),
        Geckoboard::PercentageField.new(:percentage_ccr_succeeded, name: 'Percentage of successful CCR injections'),
        Geckoboard::NumberField.new(:total_cclf_succeeded, name: 'Total CCLF succeeded'),
        Geckoboard::NumberField.new(:total_cclf, name: 'Total number of CCLF injections'),
        Geckoboard::PercentageField.new(:percentage_cclf_succeeded, name: 'Percentage of successful CCLF injections'),
        Geckoboard::NumberField.new(:total_succeeded, name: 'Total succeeded'),
        Geckoboard::NumberField.new(:total, name: 'Total number of injections')
      ].map { |field| [field.class, field.id, field.name] }
    end

    it { is_expected.to eq expected_fields }
  end

  describe '#items' do
    subject { described_class.new.items }

    let(:expected_items) do
      [
        {
          date: '2017-03-19',
          total_ccr_succeeded: 3,
          total_ccr: 5,
          percentage_ccr_succeeded: 0.6,
          total_cclf_succeeded: 1,
          total_cclf: 6,
          percentage_cclf_succeeded: 0.16666666666666666,
          total_succeeded: 4,
          total: 11
        },
        {
          date: '2017-03-20',
          total_ccr_succeeded: 2,
          total_ccr: 6,
          percentage_ccr_succeeded: 0.3333333333333333,
          total_cclf_succeeded: 3,
          total_cclf: 6,
          percentage_cclf_succeeded: 0.5,
          total_succeeded: 5,
          total: 12
        },
        {
          date: '2017-03-21',
          total_ccr_succeeded: 5,
          total_ccr: 6,
          percentage_ccr_succeeded: 0.8333333333333334,
          total_cclf_succeeded: 0,
          total_cclf: 7,
          percentage_cclf_succeeded: 0.0,
          total_succeeded: 5,
          total: 13
        }
      ]
    end

    before do
      agfs_claim = create(:advocate_claim)
      lgfs_claim = create(:litigator_claim)

      travel_to(Date.parse('19-MAR-2017')) do
        create_list(:injection_attempt, 3, claim: agfs_claim)
        create_list(:injection_attempt, 2, :with_errors, claim: agfs_claim)
        create_list(:injection_attempt, 1, :with_stat_excluded_errors, claim: agfs_claim)

        create_list(:injection_attempt, 1, claim: lgfs_claim)
        create_list(:injection_attempt, 5, :with_errors, claim: lgfs_claim)
      end

      travel_to(Date.parse('20-MAR-2017')) do
        create_list(:injection_attempt, 2, claim: agfs_claim)
        create_list(:injection_attempt, 4, :with_errors, claim: agfs_claim)

        create_list(:injection_attempt, 3, claim: lgfs_claim)
        create_list(:injection_attempt, 3, :with_errors, claim: lgfs_claim)
      end

      travel_to(Date.parse('21-MAR-2017')) do
        create_list(:injection_attempt, 5, claim: agfs_claim)
        create_list(:injection_attempt, 1, :with_errors, claim: agfs_claim)

        create_list(:injection_attempt, 0, claim: lgfs_claim)
        create_list(:injection_attempt, 7, :with_errors, claim: lgfs_claim)
      end
    end

    include_examples 'returns valid items structure'

    it 'returns dates to day precision in ISO 8601 format - YYYY-MM-DD' do
      expect(subject.first[:date]).to match(/^(\d{4}-(0[1-9]|1[0-2])-((0[1-9]|[12]\d)|3[01]))$/)
    end

    context 'when run without parameters' do
      it 'returns expected data item count' do
        expect(subject.size).to eql 1
      end

      it { is_expected.to match_array(
        [
          {
            date: Date.yesterday.to_s(:db),
            total_ccr_succeeded: 0,
            total_ccr: 0,
            percentage_ccr_succeeded: 0.0,
            total_cclf_succeeded: 0,
            total_cclf: 0,
            percentage_cclf_succeeded: 0.0,
            total_succeeded: 0,
            total: 0
          }
        ])
      }
    end

    context 'when run with parameters' do
      subject { described_class.new(start_date, end_date).items }

      let(:start_date) { Date.new(2017, 3, 19) }
      let(:end_date) { Date.new(2017, 3, 21) }

      let(:total_excluding_error) do
        InjectionAttempt
        .where(created_at: start_date)
        .exclude_error('%already exist%')
        .count
      end

      it 'excludes errors that are considered warnings' do
        item = expected_items.find { |item| item[:date].eql?(start_date.to_s(:db)) }
        expect(item[:total]).to eql(total_excluding_error)
      end

      it 'returns expected data item count' do
        expect(subject.size).to eql 3
      end

      it 'returns the expected items' do
        expected_items.each do |item|
          is_expected.to include item
        end
      end
    end
  end
end
