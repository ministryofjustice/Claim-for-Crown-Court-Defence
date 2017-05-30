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
            { value: 7.853403141361256, text: 'Rejected/refused'},
            { value: 20.94240837696335, text: 'Part authorised' },
            { value: 71.20418848167539, text: 'Authorised' }
          ]
        }
    end
  end
end
