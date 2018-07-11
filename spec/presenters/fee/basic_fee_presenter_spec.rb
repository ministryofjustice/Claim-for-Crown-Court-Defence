require 'rails_helper'

RSpec.describe Fee::BasicFeePresenter, type: :presenter do
  let(:claim) { create(:advocate_claim, :agfs_scheme_10) }
  let(:claim_9) { create(:advocate_claim, :agfs_scheme_9) }
  let(:fee) { build(:basic_fee, claim: claim) }
  let!(:lgfs_scheme_nine) { FeeScheme.find_by(name: 'LGFS', version: 9) || create(:fee_scheme, :lgfs_nine) }
  let!(:agfs_scheme_nine) { FeeScheme.find_by(name: 'AGFS', version: 9) || create(:fee_scheme, :agfs_nine) }
  let!(:agfs_scheme_ten) { FeeScheme.find_by(name: 'AGFS', version: 10) || create(:fee_scheme) }

  subject(:presenter) { described_class.new(fee, view) }

  describe '#prompt_text' do
    context 'when the fee type code does not require a prompt text' do
      let(:fee) { build(:basic_fee, :daf_fee, claim: claim) }

      specify { expect(presenter.prompt_text).to be_nil }
    end

    context 'when the fee type code is BAF' do
      context 'and the claim is under the original fee scheme' do
        let(:fee) { build(:basic_fee, :baf_fee, claim: claim_9) }

        specify { expect(presenter.prompt_text).to eq("Please include dates for those Standard appearance fees and PTPH's included in the Basic Fee\n") }
      end

      context 'and the claim is under the fee reform scheme' do
        let(:fee) { build(:basic_fee, :baf_fee, claim: claim) }

        specify { expect(presenter.prompt_text).to eq("The basic fee for Scheme 10 claims includes the first day of trial and 3 conferences and views. All other hearings must be added in the relevant sections below\n") }
      end
    end

    context 'when the fee type code is SAF' do
      context 'and the claim is under the original fee scheme' do
        let(:fee) { build(:basic_fee, :saf_fee, claim: claim_9) }

        specify { expect(presenter.prompt_text).to eq("Include any additional PTPH fees under SAF") }
      end
      context 'and the claim is under the fee reform scheme' do
        let(:fee) { build(:basic_fee, :saf_fee, claim: claim) }

        specify { expect(presenter.prompt_text).to be_nil }
      end
    end

    context 'when the fee type code is PPE' do
      context 'and the claim is under the original fee scheme' do
        let(:fee) { build(:basic_fee, :ppe_fee, claim: claim_9) }

        specify { expect(presenter.prompt_text).to be_nil }
      end

      context 'and the claim is under the fee reform scheme' do
        let(:fee) { build(:basic_fee, :ppe_fee, claim: claim) }

        specify { expect(presenter.prompt_text).to eq("Please enter the volume of PPE to help the caseworker assess the correct offence band\n") }
      end
    end
  end

  describe '#display_amount?' do
    context 'when the associated claim is not under the new fee reform' do
      let(:fee) { build(:basic_fee, :baf_fee, claim: claim_9) }

      specify { expect(presenter.display_amount?).to be_truthy }
    end

    context 'when the associated claim is under the new fee reform' do
      context 'but the fee type code is not included in the blacklist' do
        let(:fee) { build(:basic_fee, :baf_fee, claim: claim) }

        specify { expect(presenter.display_amount?).to be_truthy }
      end

      context 'but the fee type code is blacklisted' do
        let(:fee) { build(:basic_fee, :ppe_fee, claim: claim) }

        specify { expect(presenter.display_amount?).to be_falsey }
      end
    end
  end

  describe '#should_be_displayed?' do
    context 'when claim is NOT under the reformed fee scheme' do
      let(:fee) { build(:basic_fee, :baf_fee, claim: claim_9) }

      specify { expect(presenter.should_be_displayed?).to be_truthy }
    end

    context 'when claim is under the reformed fee scheme' do
      context 'but fee type does not have any restrictions to be displayed' do
        let(:fee) { build(:basic_fee, :baf_fee, claim: claim) }

        specify { expect(presenter.should_be_displayed?).to be_truthy }
      end

      context 'and fee type has restrictions to be displayed' do
        let(:fee) { build(:basic_fee, :ppe_fee, claim: claim) }

        context 'and the offence category number is neither 6 or 9' do
          let!(:offence) {
            create(:offence, :with_fee_scheme_ten,
                   offence_band: create(:offence_band,
                                        offence_category: create(:offence_category, number: 2))) }
          let(:claim) { build(:advocate_claim, offence: offence) }

          specify { expect(presenter.should_be_displayed?).to be_falsey }
        end

        context 'and the offence category number is 6' do
          let!(:offence) {
            create(:offence, :with_fee_scheme_ten,
                   offence_band: create(:offence_band,
                                        offence_category: create(:offence_category, number: 6))) }
          let(:claim) { build(:advocate_claim, offence: offence) }

          specify { expect(presenter.should_be_displayed?).to be_truthy }
        end

        context 'and the offence category number is 9' do
          let!(:offence) {
            create(:offence, :with_fee_scheme_ten,
                   offence_band: create(:offence_band,
                                        offence_category: create(:offence_category, number: 9))) }
          let(:claim) { build(:advocate_claim, offence: offence) }

          specify { expect(presenter.should_be_displayed?).to be_truthy }
        end
      end
    end
  end
end
