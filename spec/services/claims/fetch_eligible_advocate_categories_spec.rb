require 'rails_helper'

RSpec.describe Claims::FetchEligibleAdvocateCategories, type: :service do
  describe '.for' do
    subject { described_class.for(claim) }

    context 'when claim is nil' do
      let(:claim) { nil }
      specify { is_expected.to eq(nil) }
    end

    context 'when claim is for an LGFS' do
      let(:claim) { build(:litigator_claim) }
      specify { is_expected.to eq(nil) }
    end

    context 'when claim is for a AGFS' do
      shared_examples_for 'an AGFS claim' do
        context 'and it is NOT on the AGFS fee reform scheme' do
          before do
            expect(claim).to receive(:fee_scheme).and_return('default')
          end

          it 'returns the default list for advocate categories' do
            is_expected.to match_array(["QC", "Led junior", "Leading junior", "Junior alone"])
          end
        end

        context 'and it is on the AGFS fee reform scheme' do
          before do
            expect(claim).to receive(:fee_scheme).and_return('fee_reform')
          end

          it 'returns the list for AGFS fee reform advocate categories' do
            is_expected.to match_array(["QC", "Leading junior", "Junior"])
          end
        end
      end

      context 'and the claim is final' do
        let(:claim) { build(:advocate_claim) }

        include_examples 'an AGFS claim'
      end

      context 'and the claim is interim' do
        let(:claim) { build(:advocate_interim_claim) }

        include_examples 'an AGFS claim'
      end
    end
  end
end
