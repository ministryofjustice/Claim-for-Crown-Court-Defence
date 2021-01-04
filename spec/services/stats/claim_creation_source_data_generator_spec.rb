require 'rails_helper'

module Stats
  describe ClaimCreationSourceDataGenerator do
    it 'produces the correct stats as json' do
      generate_stats_data
      result = ClaimCreationSourceDataGenerator.new.run
      expect(result).to be_instance_of(GeckoWidgets::LineGraph)
      expect(result.to_json).to eq expected_json
    end

    def expected_json
      {
        'x_axis' => {
          'labels' => ['-3', '-2', '-1'] },
        'series' => [
          { 'name' => 'Web', 'data' => [66, 36, 6] },
          { 'name' => 'API', 'data' => [22, 12, 2] },
          { 'name' => 'JSON', 'data' => [44, 24, 4] }
        ]
      }.to_json
    end

    def generate_stats_data
      {
        'web' => 3,
        'json' => 2,
        'api' => 1
      }.each do |source, multiplier|
        [2, 12, 22].each do |days_ago|
          Statistic.create!(
            date: days_ago.days.ago,
            report_name: "creations_source_#{source}",
            claim_type: 'Claim::BaseClaim',
            value_1: days_ago * multiplier,
            value_2: 0
          )
        end
      end
    end
  end
end
