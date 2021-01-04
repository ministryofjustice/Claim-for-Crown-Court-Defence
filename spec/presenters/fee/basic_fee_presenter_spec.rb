require 'rails_helper'

RSpec.describe Fee::BasicFeePresenter, type: :presenter do
  let(:claim) { create(:advocate_claim, :agfs_scheme_10) }
  let(:claim_9) { create(:advocate_claim, :agfs_scheme_9) }
  let(:fee) { build(:basic_fee, claim: claim) }

  before { seed_fee_schemes }

  subject(:presenter) { described_class.new(fee, view) }

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
        let(:offence) do
          create(
            :offence, :with_fee_scheme_ten,
            offence_band: create(:offence_band, offence_category: offence_category)
          )
        end
        let(:claim) { build(:advocate_claim, offence: offence) }

        context 'and the offence category number is neither 6 or 9' do
          let(:offence_category) { build :offence_category, number: 2 }

          specify { expect(presenter.should_be_displayed?).to be_falsey }
        end

        context 'and the offence category number is 6' do
          let(:offence_category) { build :offence_category, number: 6 }

          specify { expect(presenter.should_be_displayed?).to be_truthy }
        end

        context 'and the offence category number is 9' do
          let(:offence_category) { build :offence_category, number: 9 }

          specify { expect(presenter.should_be_displayed?).to be_truthy }
        end
      end
    end
  end

  describe '#display_extra_fees?' do
    # method calls #should_be_displayed? after discontinuance
    # guard clause test logic other than this is covered.
    context 'should return false if claim is discontinuance' do
      let(:discontinuance) { create(:case_type, :discontinuance) }
      let(:claim_9) { create(:advocate_claim, :agfs_scheme_9, case_type: discontinuance) }
      let(:fee) { build(:basic_fee, :baf_fee, claim: claim_9) }
      specify { expect(presenter.display_extra_fees?).to be_falsey }
    end
  end

  describe '#display_help_text?' do
    context 'when claim is NOT under the reformed fee scheme' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_9) }

      specify { expect(presenter.display_help_text?).to be_falsey }
    end

    context 'when claim is under the reformed fee scheme' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_10) }

      context 'and fee type has restrictions to be displayed' do
        let(:fee) { build(:basic_fee, :ppe_fee, claim: claim) }
        let(:offence) do
          create(
            :offence, :with_fee_scheme_ten,
            offence_band: create(:offence_band, offence_category: offence_category)
          )
        end
        let(:claim) { build(:advocate_claim, offence: offence) }

        context 'and the offence category number is neither 6 or 9' do
          let(:offence_category) { build :offence_category, number: 2 }

          specify { expect(presenter.display_help_text?).to be_falsey }
        end

        context 'and the offence category number is 6' do
          let(:offence_category) { build :offence_category, number: 6 }

          specify { expect(presenter.display_help_text?).to be_truthy }
        end

        context 'and the offence category number is 9' do
          let(:offence_category) { build :offence_category, number: 9 }

          specify { expect(presenter.display_help_text?).to be_truthy }
        end
      end
    end
  end

  describe '#fee_calc_class' do
    subject { presenter.fee_calc_class }

    context 'when fee is pages of prosecution evidence (ppe)' do
      let(:fee) { build(:basic_fee, :ppe_fee, claim: claim) }
      it { is_expected.to eq('js-fee-calculator-ppe') }
    end

    context 'when fee is number of prosecution witnesses (npw)' do
      let(:fee) { build(:basic_fee, :npw_fee, claim: claim) }
      it { is_expected.to eq('js-fee-calculator-pw') }
    end
  end
end
