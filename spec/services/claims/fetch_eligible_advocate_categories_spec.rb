require 'rails_helper'

RSpec.describe Claims::FetchEligibleAdvocateCategories, type: :service do
  describe '.for' do
    subject { described_class.for(claim) }

    context 'nil claim' do
      let(:claim) { nil }
      specify { is_expected.to eq(nil) }
    end

    context 'LGFS claim' do
      let(:claim) { build(:litigator_claim) }
      specify { is_expected.to eq(nil) }
    end

    context 'AGFS claim' do
      shared_examples_for 'AGFS fee reform dependant advocate categories' do
        context 'default scheme' do
          before do
            expect(claim).to receive(:fee_scheme).and_return('default')
          end

          it 'returns the default list for advocate categories' do
            is_expected.to match_array(["QC", "Led junior", "Leading junior", "Junior alone"])
          end
        end

        context 'fee reform scheme' do
          before do
            expect(claim).to receive(:fee_scheme).and_return('fee_reform')
          end

          it 'returns the list for AGFS fee reform advocate categories' do
            is_expected.to match_array(["QC", "Leading junior", "Junior"])
          end
        end

        context 'scheme 9 object' do
          let(:agfs_scheme_nine) { FeeScheme.find_by(name: 'AGFS', version: 9) || create(:fee_scheme, :agfs_nine) }

          before do
            expect(claim).to receive(:fee_scheme).at_least(:once).and_return(agfs_scheme_nine)
          end

          it 'returns the list for AGFS scheme 9 advocate categories' do
            is_expected.to match_array(["QC", "Led junior", "Leading junior", "Junior alone"])
          end
        end

        context 'scheme 10 object' do
          let(:agfs_scheme_ten) { FeeScheme.find_by(name: 'AGFS', version: 10) || create(:fee_scheme) }

          before do
            expect(claim).to receive(:fee_scheme).at_least(:once).and_return(agfs_scheme_ten)
          end

          it 'returns the list for AGFS scheme 10 advocate categories' do
            is_expected.to match_array(["QC", "Leading junior", "Junior"])
          end
        end
      end

      context 'when the claim is final' do
        let(:claim) { build(:advocate_claim) }

        include_examples 'AGFS fee reform dependant advocate categories'
      end

      context 'when the claim is interim' do
        let(:claim) { build(:advocate_interim_claim) }

        include_examples 'AGFS fee reform dependant advocate categories'
      end

      context 'when the claim has been submitted via the API' do
        # This will mean the offence will determine the fee_scheme, not the rep_order date
        context 'with a scheme 10 offence' do
          let(:claim) { create :api_advocate_claim, :with_scheme_ten_offence }

          it { is_expected.to match_array(['QC', 'Leading junior', 'Junior']) }
        end

        context 'with a scheme 9 offence' do
          let(:claim) { create :api_advocate_claim }

          it { is_expected.to match_array(['QC', 'Led junior', 'Leading junior', 'Junior alone']) }
        end
      end
    end
  end
end
