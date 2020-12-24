require 'rails_helper'

RSpec.describe GeckoboardPublisher::ProvidersReport, geckoboard: true do
  it_behaves_like 'geckoboard publishable report'

  # calls to api.geckoboard.com are stubbed in rails_helper in case future reports are generated

  describe '#fields' do
    subject { described_class.new.fields.map { |field| [field.class, field.id, field.name] } }

    let(:expected_fields) do
      [
        Geckoboard::DateField.new(:date, name: 'Date'),
        Geckoboard::NumberField.new(:firms_added, name: 'Firms added'),
        Geckoboard::NumberField.new(:chambers_added, name: 'Chambers added'),
        Geckoboard::NumberField.new(:total_added, name: 'Total created'),
        Geckoboard::NumberField.new(:overall_count, name: 'Overall provider count')
      ].map { |field| [field.class, field.id, field.name] }
    end

    it { is_expected.to eq expected_fields }
  end

  describe '#items' do
    subject { described_class.new.items }

    let(:expected_items) do
      [
        {
          firms_added: 0,
          chambers_added: 1,
          total_added: 1,
          date: '2017-03-19',
          overall_count: 1
        },
        {
          firms_added: 1,
          chambers_added: 1,
          total_added: 2,
          date: '2017-03-20',
          overall_count: 3
        },
        {
          firms_added: 0,
          chambers_added: 1,
          total_added: 1,
          date: '2017-03-21',
          overall_count: 4
        }
      ]
    end

    before do
      create(:provider, created_at: Date.parse('19-MAR-2017'))
      create(:provider, :agfs, created_at: Date.parse('20-MAR-2017 12:43'))
      create(:provider, :lgfs, created_at: Date.parse('20-MAR-2017 13:32'))
      create(:provider, created_at: Date.parse('21-MAR-2017 09:00'))
    end

    before { travel_to Date.parse('22-MAR-2017') }
    after { travel_back }

    include_examples 'returns valid items structure'

    it 'returns dates to day precision in ISO 8601 format - YYYY-MM-DD' do
      expect(subject.first[:date]).to match /^(\d{4}-(0[1-9]|1[0-2])-((0[1-9]|[12]\d)|3[01]))$/
    end

    context 'when run without parameters' do
      it 'returns expected data item count' do
        expect(subject.size).to eql 1
      end

      it { is_expected.to include expected_items.last }
    end

    context 'when run with parameters' do
      subject { described_class.new(start_date, end_date).items }

      let(:start_date) { Date.new(2017, 3, 19) }
      let(:end_date) { Date.new(2017, 3, 21) }

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
