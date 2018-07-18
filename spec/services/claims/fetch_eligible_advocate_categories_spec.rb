require 'rails_helper'

RSpec.describe Claims::FetchEligibleAdvocateCategories, type: :service do
  before do
    FeeScheme.find_by(name: 'LGFS', version: 9) || create(:fee_scheme, :lgfs_nine)
    FeeScheme.find_by(name: 'AGFS', version: 9) || create(:fee_scheme, :agfs_nine)
    FeeScheme.find_by(name: 'AGFS', version: 10) || create(:fee_scheme, :agfs_ten)
  end

  let(:scheme_9_advocate_categories) { ['QC', 'Led junior', 'Leading junior', 'Junior alone']}
  let(:scheme_10_advocate_categories) { ['QC', 'Leading junior', 'Junior']}

  describe '.for' do
    subject { described_class.for(claim) }

    context 'nil claim' do
      let(:claim) { nil }
      it { is_expected.to eq(nil) }
    end

    context 'LGFS claim' do
      let(:claim) { build(:litigator_claim) }
      it { is_expected.to eq(nil) }
    end

    context 'AGFS claim' do
      context 'when the claim is final' do
        context 'scheme 9' do
          let(:claim) { create(:advocate_claim, :agfs_scheme_9) }

          it 'returns the list for AGFS scheme 9 advocate categories' do
            is_expected.to match_array(scheme_9_advocate_categories)
          end
        end

        context 'scheme 10' do
          let(:claim) { create(:advocate_claim, :agfs_scheme_10) }

          it 'returns the list for AGFS scheme 10 advocate categories' do
            is_expected.to match_array(scheme_10_advocate_categories)
          end
        end
      end

      context 'when the claim is interim' do
        # FIXME: this kind of claim should be invalid for scheme 9 at any point
        context 'scheme 9' do
          let(:claim) { create(:advocate_interim_claim, :agfs_scheme_9) }

          it 'returns the list for AGFS scheme 9 advocate categories' do
            is_expected.to match_array(scheme_9_advocate_categories)
          end
        end

        context 'scheme 10' do
          let(:claim) { create(:advocate_interim_claim, :agfs_scheme_10) }

          it 'returns the list for AGFS scheme 10 advocate categories' do
            is_expected.to match_array(scheme_10_advocate_categories)
          end
        end
      end

      context 'when the claim has been submitted via the API' do
        # This will mean the offence will determine the fee_scheme, not the rep_order date
        context 'with a scheme 10 offence' do
          let(:claim) { create :api_advocate_claim, :with_scheme_ten_offence }

          it { is_expected.to match_array(scheme_10_advocate_categories) }
        end

        context 'with a scheme 9 offence' do
          let(:claim) { create :api_advocate_claim }

          it { is_expected.to match_array(scheme_9_advocate_categories) }
        end
      end
    end
  end
end
