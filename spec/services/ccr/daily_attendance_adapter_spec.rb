require 'rails_helper'

RSpec.describe CCR::DailyAttendanceAdapter, type: :adapter do
  let(:retrial) { create(:case_type, :retrial) }

  before do
    FeeScheme.find_by(name: 'LGFS', version: 9) || create(:fee_scheme, :lgfs_nine)
    FeeScheme.find_by(name: 'AGFS', version: 9) || create(:fee_scheme, :agfs_nine)
    FeeScheme.find_by(name: 'AGFS', version: 10) || create(:fee_scheme)
  end

  describe '#attendances' do
    subject { described_class.new(claim).attendances }

    context 'scheme 9 claim' do
      let(:claim) { create(:authorised_claim, case_type: case_type) }
      attendances_incl_in_basic_fee = 2

      context 'for trials' do
        let(:case_type) { build(:case_type, :trial) }

        context 'when no daily attendance uplift fees applied' do
          [0,1,3,nil].each do |trial_length|
            context "and claim has an actual trial length of #{trial_length || 'nil'}" do
              before { claim.update(actual_trial_length: trial_length) }
              it "returns #{[trial_length, attendances_incl_in_basic_fee].compact.min} - as least of actual trial length or #{attendances_incl_in_basic_fee} (included in basic fee)" do
                is_expected.to eql [trial_length, attendances_incl_in_basic_fee].compact.min
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

          it "returns sum of daily attendance fee types plus #{attendances_incl_in_basic_fee} (included in basic fee)" do
            is_expected.to eql 51
          end
        end
      end

      context 'for retrials' do
        let(:case_type) { build(:case_type, :retrial) }

        context 'when no daily attendance uplift fees applied' do
          [0,1,3,nil].each do |trial_length|
            context "and claim has an actual retrial length of #{trial_length || 'nil'}" do
              before { claim.update(retrial_actual_length: trial_length) }
              it "returns #{[trial_length, attendances_incl_in_basic_fee].compact.min} - as least of actual retrial length or 2 (included in basic fee)" do
                is_expected.to eql [trial_length,2].compact.min
              end
            end
          end
        end
      end
    end

    context 'scheme 10 claim' do
      let(:claim) { create(:authorised_claim, :agfs_scheme_10, case_type: case_type, form_step: :case_details, offence: create(:offence, :with_fee_scheme_ten)) }
      attendances_incl_in_basic_fee = 1

      context 'for trials' do
        let(:case_type) { build(:case_type, :trial) }

        context 'when no daily attendance uplift fee (2+) applied' do
          [0,1,2,nil].each do |trial_length|
            context "and claim has an actual trial length of #{trial_length || 'nil'}" do
              before { claim.update(actual_trial_length: trial_length) }
              it "returns #{[trial_length, attendances_incl_in_basic_fee].compact.min} - as least of actual trial length or #{attendances_incl_in_basic_fee} (included in basic fee)" do
                is_expected.to eql [trial_length, attendances_incl_in_basic_fee].compact.min
              end
            end
          end
        end

        context 'when daily attendance uplift fees applied' do
          before do
            claim.actual_trial_length = 10
            create(:basic_fee, :dat_fee, claim: claim, quantity: 9, rate: 1.0)
          end

          it "returns sum of daily attendance fee types plus #{attendances_incl_in_basic_fee} (included in basic fee)" do
            is_expected.to eql 10
          end
        end
      end

      context 'for retrials' do
        let(:case_type) { build(:case_type, :retrial) }

        context 'when no daily attendance uplift fee (2+) applied' do
          [0,1,2,nil].each do |trial_length|
            context "and claim has an actual retrial length of #{trial_length || 'nil'}" do
              before { claim.update(retrial_actual_length: trial_length) }
              it "returns #{[trial_length, attendances_incl_in_basic_fee].compact.min} - as least of actual retrial length or #{attendances_incl_in_basic_fee} (included in basic fee)" do
                is_expected.to eql [trial_length, attendances_incl_in_basic_fee].compact.min
              end
            end
          end
        end
      end
    end
  end

  describe '.attendances_for' do
    subject { described_class.attendances_for(claim) }
    let(:claim) { build(:authorised_claim) }
    let(:adapter) { instance_double 'DailyAttendanceAdapter' }

    it 'calls #attendances' do
      expect(described_class).to receive(:new).with(claim).and_return adapter
      expect(adapter).to receive(:attendances)
      subject
    end
  end
end
