require 'rails_helper'


module TimedTransitions
  describe BatchTransitioner do
    it 'should instantiate a Transitioner and run it for each claim' do
      bt = BatchTransitioner.new

      claims = %w{mock_claim_1 mock_claim_2}
      expect(Transitioner).to receive(:candidate_claims).and_return(claims)
      transitioner_1 = double Transitioner
      transitioner_2 = double Transitioner
      expect(Transitioner).to receive(:new).with('mock_claim_1').and_return(transitioner_1)
      expect(Transitioner).to receive(:new).with('mock_claim_2').and_return(transitioner_2)
      expect(transitioner_1).to receive(:run)
      expect(transitioner_2).to receive(:run)

      bt.run
    end
  end
end
