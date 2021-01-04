require 'rails_helper'

module Stats

  describe ClaimSubmissionsDataGenerator do
    it 'should instantiate' do
      populate_statistics_table
      expect(ClaimSubmissionsDataGenerator.new.run.to_json).to eq expected_output.to_json
    end

    def populate_statistics_table
      advocates = [250, 260, 270, 280, 290]
      interims = [150, 160, 170, 180, 190]
      litigators = [350, 360, 370, 380, 390]
      transfers = [50, 60, 70 ,80, 90]

      populate_statistics_records('Advocate', advocates)
      populate_statistics_records('Interim', interims)
      populate_statistics_records('Litigator', litigators)
      populate_statistics_records('Transfer', transfers)
    end

    def populate_statistics_records(abbreviated_claim_type, dataset)
      date = Date.yesterday - dataset.size.days
      claim_type = "Claim::#{abbreviated_claim_type}Claim"
      dataset.each do |data_value|
        Statistic.create(report_name: 'claim_submissions', claim_type: claim_type, date: date, value_1: data_value)
        date += 1.day
      end
    end

    def expected_output
      {
        'x_axis' => {
          'labels' => %w{-5 -4 -3 -2 -1}
        },
        'series' => [
          {
            'name' => 'Advocate',
            'data' => [250, 260, 270, 280, 290]
          },
          {
            'name' => 'Litigator interim',
            'data' => [150, 160, 170, 180, 190]
          },
          {
            'name' => 'Litigator final',
            'data' => [350, 360, 370, 380, 390]
          },
          {
            'name' => 'Litigator transfer',
            'data' => [50, 60, 70 ,80, 90]
          }
        ]
      }
    end
  end
end
