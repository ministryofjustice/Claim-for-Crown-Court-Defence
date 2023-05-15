require 'rails_helper'

RSpec.shared_examples 'list of advocate categories for' do |claim_type|
  context 'with scheme 9' do
    let(:claim) { create(claim_type, :agfs_scheme_9) }

    it 'returns the list for AGFS scheme 9 advocate categories' do
      is_expected.to eq(['Junior alone', 'Leading junior', 'Led junior', 'QC'])
    end
  end

  context 'with scheme 10' do
    let(:claim) { create(claim_type, :agfs_scheme_10) }

    it 'returns the list for AGFS scheme 10 advocate categories' do
      is_expected.to eq(['Junior', 'Leading junior', 'QC'])
    end
  end

  context 'with scheme 15' do
    let(:claim) { create(claim_type, :agfs_scheme_15) }

    it 'returns the list for AGFS scheme 15 advocate categories' do
      is_expected.to eq(['Junior', 'Leading junior', 'KC'])
    end
  end
end

RSpec.describe Claims::FetchEligibleAdvocateCategories, type: :service do
  describe '.for' do
    subject { described_class.for(claim) }

    context 'with a nil claim' do
      let(:claim) { nil }

      it { is_expected.to be_nil }
    end

    context 'with an LGFS claim' do
      let(:claim) { build(:litigator_claim) }

      it { is_expected.to be_nil }
    end

    it_behaves_like 'list of advocate categories for', :advocate_claim

    # FIXME: this kind of claim should be invalid for scheme 9 at any point
    it_behaves_like 'list of advocate categories for', :advocate_interim_claim

    context 'when the claim has been submitted via the API' do
      # This will mean the offence will determine the fee_scheme, not the rep_order date
      context 'with a scheme 9 offence' do
        let(:claim) { create(:api_advocate_claim, :with_scheme_nine_offence) }

        it { is_expected.to eq(['Junior alone', 'Leading junior', 'Led junior', 'QC']) }
      end

      context 'with a scheme 10 offence' do
        let(:claim) { create(:api_advocate_claim, :with_scheme_ten_offence) }

        it { is_expected.to eq(['Junior', 'Leading junior', 'QC']) }
      end

      context 'with a scheme 15 offence' do
        let(:claim) { create(:api_advocate_claim, :with_scheme_fifteen_offence) }

        it { is_expected.to eq(['Junior', 'Leading junior', 'KC']) }
      end

      context 'with no offence (fixed fee case type)' do
        let(:claim) { create(:api_advocate_claim, :with_no_offence) }

        it { is_expected.to eq(['Junior', 'Junior alone', 'Leading junior', 'Led junior', 'QC', 'KC']) }
      end
    end
  end
end
