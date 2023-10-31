require 'rails_helper'

RSpec.shared_examples 'find claims for fee scheme' do |name, version|
  let(:fee_scheme) { FeeScheme.find_by(name:, version:) }

  let!(:expected_claims) do
    expected_claims_details.map do |details|
      create(details[:factory], create_defendant_and_rep_order: false).tap do |claim|
        rep_order = create(:representation_order, representation_order_date: details[:rep_order_date])
        create(:defendant, claim:, representation_orders: [rep_order])
        if details[:main_hearing_date]
          claim.main_hearing_date = details[:main_hearing_date]
          claim.save
        end
      end
    end
  end

  before do
    other_claims_details.each do |details|
      create(details[:factory], create_defendant_and_rep_order: false).tap do |claim|
        rep_order = create(:representation_order, representation_order_date: details[:rep_order_date])
        create(:defendant, claim:, representation_orders: [rep_order])
        if details[:main_hearing_date]
          claim.main_hearing_date = details[:main_hearing_date]
          claim.save
        end
      end
    end
  end

  it { is_expected.to match_array(expected_claims) }
end

RSpec.describe FeeScheme do
  let(:lgfs_scheme_nine) { FeeScheme.find_by(name: 'LGFS', version: 9) }
  let(:lgfs_scheme_ten) { FeeScheme.find_by(name: 'LGFS', version: 10) }
  let(:agfs_scheme_nine) { FeeScheme.find_by(name: 'AGFS', version: 9) }
  let(:agfs_scheme_ten) { FeeScheme.find_by(name: 'AGFS', version: 10) }
  let(:agfs_scheme_eleven) { FeeScheme.find_by(name: 'AGFS', version: 11) }
  let(:agfs_scheme_twelve) { FeeScheme.find_by(name: 'AGFS', version: 12) }
  let(:agfs_scheme_thirteen) { FeeScheme.find_by(name: 'AGFS', version: 13) }
  let(:fee_scheme) { claim.fee_scheme }

  it { should validate_presence_of(:start_date) }
  it { should validate_presence_of(:version) }
  it { should validate_presence_of(:name) }

  it { is_expected.to respond_to(:agfs?, :agfs_reform?, :agfs_scheme_12?) }

  describe '#agfs?' do
    subject(:agfs?) { fee_scheme.agfs? }

    context 'with an agfs scheme 10 claim' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_10) }

      it { is_expected.to be_truthy }
    end

    context 'with an lgfs claim' do
      let(:claim) { create(:litigator_claim) }

      it { is_expected.to be_falsey }
    end
  end

  describe '#agfs_reform?' do
    subject(:agfs_reform?) { fee_scheme.agfs_reform? }

    context 'with an agfs scheme 10 claim' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_10) }

      it { is_expected.to be_truthy }
    end

    context 'with an agfs scheme 9 claim' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_9) }

      it { is_expected.to be_falsey }
    end

    context 'with an lgfs claim' do
      let(:claim) { create(:litigator_claim) }

      it { is_expected.to be_falsey }
    end
  end

  describe '#agfs_scheme_12?' do
    subject { fee_scheme.agfs_scheme_12? }

    context 'with an agfs scheme 13 claim' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_13) }

      it { is_expected.to be_falsey }
    end

    context 'with an agfs scheme 12 claim' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_12) }

      it { is_expected.to be_truthy }
    end

    context 'with an agfs scheme 10 claim' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_10) }

      it { is_expected.to be_falsey }
    end

    context 'with an agfs scheme 9 claim' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_9) }

      it { is_expected.to be_falsey }
    end

    context 'with an lgfs claim' do
      let(:claim) { create(:litigator_claim) }

      it { is_expected.to be_falsey }
    end
  end

  describe '#agfs_scheme_13?' do
    subject { fee_scheme.agfs_scheme_13? }

    context 'with an agfs scheme 13 claim' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_13) }

      it { is_expected.to be_truthy }
    end

    context 'with an agfs scheme 12 claim' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_12) }

      it { is_expected.to be_falsey }
    end

    context 'with an agfs scheme 10 claim' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_10) }

      it { is_expected.to be_falsey }
    end

    context 'with an agfs scheme 9 claim' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_9) }

      it { is_expected.to be_falsey }
    end

    context 'with an lgfs claim' do
      let(:claim) { create(:litigator_claim) }

      it { is_expected.to be_falsey }
    end
  end

  describe '#claims' do
    subject { fee_scheme.claims }

    it_behaves_like 'find claims for fee scheme', 'AGFS', 9 do
      let(:expected_claims_details) do
        [
          { factory: :advocate_claim, rep_order_date: Settings.agfs_fee_reform_release_date - 1.day }
        ]
      end
      let(:other_claims_details) do
        [
          { factory: :advocate_claim, rep_order_date: Settings.agfs_fee_reform_release_date },
          { factory: :litigator_claim, rep_order_date: Settings.lgfs_scheme_10_clair_release_date }
        ]
      end
    end

    it_behaves_like 'find claims for fee scheme', 'AGFS', 10 do
      let(:expected_claims_details) do
        [
          { factory: :advocate_claim, rep_order_date: Settings.agfs_fee_reform_release_date },
          { factory: :advocate_claim, rep_order_date: Settings.agfs_scheme_11_release_date - 1.day }
        ]
      end
      let(:other_claims_details) do
        [
          { factory: :advocate_claim, rep_order_date: Settings.agfs_fee_reform_release_date - 1.day },
          { factory: :advocate_claim, rep_order_date: Settings.agfs_scheme_11_release_date },
          { factory: :litigator_claim, rep_order_date: Settings.lgfs_scheme_10_clair_release_date }
        ]
      end
    end

    it_behaves_like 'find claims for fee scheme', 'AGFS', 11 do
      let(:expected_claims_details) do
        [
          { factory: :advocate_claim, rep_order_date: Settings.agfs_scheme_11_release_date },
          { factory: :advocate_claim, rep_order_date: Settings.clar_release_date - 1.day }
        ]
      end
      let(:other_claims_details) do
        [
          { factory: :advocate_claim, rep_order_date: Settings.agfs_scheme_11_release_date - 1.day },
          { factory: :advocate_claim, rep_order_date: Settings.clar_release_date },
          { factory: :litigator_claim, rep_order_date: Settings.lgfs_scheme_10_clair_release_date }
        ]
      end
    end

    it_behaves_like 'find claims for fee scheme', 'AGFS', 12 do
      let(:expected_claims_details) do
        [
          { factory: :advocate_claim, rep_order_date: Settings.clar_release_date },
          { factory: :advocate_claim, rep_order_date: Settings.agfs_scheme_13_clair_release_date - 1.day },
          {
            factory: :advocate_claim,
            rep_order_date: Settings.clar_release_date,
            main_hearing_date: Settings.clair_contingency_date - 1.day
          }
        ]
      end
      let(:other_claims_details) do
        [
          { factory: :advocate_claim, rep_order_date: Settings.clar_release_date - 1.day },
          { factory: :advocate_claim, rep_order_date: Settings.agfs_scheme_13_clair_release_date },
          {
            factory: :advocate_claim,
            rep_order_date: Settings.clar_release_date,
            main_hearing_date: Settings.clair_contingency_date
          },
          { factory: :litigator_claim, rep_order_date: Settings.lgfs_scheme_10_clair_release_date }
        ]
      end
    end

    it_behaves_like 'find claims for fee scheme', 'AGFS', 13 do
      let(:expected_claims_details) do
        [
          { factory: :advocate_claim, rep_order_date: Settings.agfs_scheme_13_clair_release_date },
          { factory: :advocate_claim, rep_order_date: Settings.agfs_scheme_14_section_twenty_eight - 1.day },
          {
            factory: :advocate_claim,
            rep_order_date: Settings.clar_release_date,
            main_hearing_date: Settings.clair_contingency_date
          }
        ]
      end
      let(:other_claims_details) do
        [
          { factory: :advocate_claim, rep_order_date: Settings.agfs_scheme_13_clair_release_date - 1.day },
          { factory: :advocate_claim, rep_order_date: Settings.agfs_scheme_14_section_twenty_eight },
          {
            factory: :advocate_claim,
            rep_order_date: Settings.clar_release_date,
            main_hearing_date: Settings.clair_contingency_date - 1.day
          },
          { factory: :litigator_claim, rep_order_date: Settings.lgfs_scheme_10_clair_release_date }
        ]
      end
    end

    it_behaves_like 'find claims for fee scheme', 'AGFS', 14 do
      let(:expected_claims_details) do
        [
          { factory: :advocate_claim, rep_order_date: Settings.agfs_scheme_14_section_twenty_eight },
          { factory: :advocate_claim, rep_order_date: Settings.agfs_scheme_15_additional_prep_fee_and_kc - 1.day }
        ]
      end
      let(:other_claims_details) do
        [
          { factory: :advocate_claim, rep_order_date: Settings.agfs_scheme_14_section_twenty_eight - 1.day },
          { factory: :advocate_claim, rep_order_date: Settings.agfs_scheme_15_additional_prep_fee_and_kc },
          { factory: :litigator_claim, rep_order_date: Settings.lgfs_scheme_10_clair_release_date }
        ]
      end
    end

    it_behaves_like 'find claims for fee scheme', 'AGFS', 15 do
      let(:expected_claims_details) do
        [
          { factory: :advocate_claim, rep_order_date: Settings.agfs_scheme_15_additional_prep_fee_and_kc }
        ]
      end
      let(:other_claims_details) do
        [
          { factory: :advocate_claim, rep_order_date: Settings.agfs_scheme_15_additional_prep_fee_and_kc - 1.day },
          { factory: :litigator_claim, rep_order_date: Settings.lgfs_scheme_10_clair_release_date }
        ]
      end
    end
  end
end
