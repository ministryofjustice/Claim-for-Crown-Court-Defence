require 'rails_helper'

module Stats
  describe ClaimPercentageAuthorisedGenerator do

    let(:generator) { ClaimPercentageAuthorisedGenerator.new }

    it 'returns a hash of percentages' do
      expect(generator).to receive(:claims_decided_this_month).with(:authorised).and_return(136)
      expect(generator).to receive(:claims_decided_this_month).with(:part_authorised).and_return(40)
      expect(generator).to receive(:claims_decided_this_month).with(:rejected).and_return(5)
      expect(generator).to receive(:claims_decided_this_month).with(:refused).and_return(10)

      expect(generator.run).to eq expected_result
    end

    def expected_result
      {
        item:
          [
            { value: 71.20418848167539, text: 'Authorised' },
            { value: 20.94240837696335, text: 'Part authorised' },
            { value: 2.6178010471204187, text: 'Rejected' },
            { value: 5.2356020942408374, text: 'Refused' }
          ]
        }
    end
  end
end
