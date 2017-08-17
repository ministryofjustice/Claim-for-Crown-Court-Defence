require 'rails_helper'

module CCR
  describe DailyAttendanceAdapter do
    subject { described_class.new(claim) }
    let(:claim) { create(:authorised_claim) }

    describe '#attendances' do
      subject { described_class.new(claim).attendances }

      context 'when no daily attendance uplift fees applied' do
        [0,1,3,nil].each do |trial_length|
          context "and claim has an actual trial length of #{trial_length || 'nil'}" do
            before { claim.update(actual_trial_length: trial_length) }
            it "returns #{[trial_length,2].compact.min} - as least of actual trial length or 2 (included in basic fee)" do
              is_expected.to eql [trial_length,2].compact.min
            end
          end
        end
      end

      context 'when daily attendance uplift fees applied' do
        before do
          claim.actual_trial_length = 51
          create(:basic_fee, :daf_fee, claim: claim, quantity: 38, rate: 1.0)
          create(:basic_fee, :dah_fee, claim: claim, quantity: 10, rate: 1.0)
          create(:basic_fee, :daj_fee, claim: claim, quantity: 1, rate: 1.0)
        end

        it 'returns sum of daily attendance fee types plus 2 (included in basic fee)' do
          is_expected.to eql 51
        end
      end
    end

    describe '.attendances_for' do
      subject { described_class.attendances_for(claim) }
      let(:adapter) { instance_double 'DailyAttendanceAdapter' }

      it 'calls #attendances' do
        expect(described_class).to receive(:new).with(claim).and_return adapter
        expect(adapter).to receive(:attendances)
        subject
      end
    end
  end
end
