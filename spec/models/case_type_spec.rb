require 'rails_helper'

RSpec.describe CaseType do
  after(:all) do
    clean_database
  end

  it_behaves_like 'roles', CaseType, CaseType::ROLES

  it { is_expected.to have_many(:case_stages).dependent(:destroy) }

  describe 'graduated_fee_type' do
    let!(:grad_fee_type)   { create(:graduated_fee_type, unique_code: 'GRAD') }
    let(:grad_case_type)   { build(:case_type, fee_type_code: 'GRAD') }
    let(:grad_case_type_x) { build(:case_type, fee_type_code: 'XXXX') }
    let(:nil_case_type)    { build(:case_type, fee_type_code: nil) }
    let!(:fixed_fee_type)  { create(:fixed_fee_type, unique_code: 'FIXED') }
    let(:fixed_case_type)  { build(:case_type, fee_type_code: 'FIXED') }

    it 'returns nil if no fee_type_code' do
      expect(fixed_case_type.graduated_fee_type).to be_nil
    end

    it 'returns the appropriate graduated fee' do
      expect(grad_case_type.graduated_fee_type).to eq grad_fee_type
    end

    it 'returns nil if the code does not exist' do
      expect(grad_case_type_x.graduated_fee_type).to be_nil
    end

    describe 'is_graduated_fee?' do
      it 'returns false if no fee_type_code' do
        expect(nil_case_type.is_graduated_fee?).to be false
      end

      it 'returns false if invalid fee_type_code' do
        expect(grad_case_type_x.is_graduated_fee?).to be false
      end

      it 'returns true if is a grad fee case type' do
        expect(grad_case_type.is_graduated_fee?).to be true
      end

      it 'returns false if it is not a grad fee case type' do
        expect(fixed_case_type.is_graduated_fee?).to be false
      end
    end
  end

  describe 'fixed_fee_type' do
    let!(:fixed_fee_type)   { create(:fixed_fee_type, unique_code: 'FIXED') }
    let(:fixed_case_type)   { build(:case_type, fee_type_code: 'FIXED') }
    let(:fixed_case_type_x) { build(:case_type, fee_type_code: 'XXXX') }
    let(:grad_case_type)    { build(:case_type, fee_type_code: nil) }

    it 'returns nil if no fee_type_code' do
      expect(grad_case_type.fixed_fee_type).to be_nil
    end

    it 'returns the appropriate fixed fee' do
      expect(fixed_case_type.fixed_fee_type).to eq fixed_fee_type
    end

    it 'returns nil if the code doesnt exist' do
      expect(fixed_case_type_x.fixed_fee_type).to be_nil
    end
  end

  describe 'is_trial_fee?' do
    subject { case_type.is_trial_fee? }

    context 'with fee_type_code matching "trial" fee case type' do
      let(:case_type) { create(:case_type, fee_type_code: 'GRTRL') }

      it { is_expected.to be_truthy }
    end

    context 'with fee_type_code not matching "trial" fee case type' do
      let(:case_type) { create(:case_type, fee_type_code: 'GRGLT') }

      it { is_expected.to be_falsey }
    end

    context 'with nil fee_type_code' do
      let(:case_type) { create(:case_type, fee_type_code: nil) }

      it { is_expected.to be_falsey }
    end
  end

  context 'scopes' do
    before(:all) { seed_case_types }

    after(:all) { destroy_case_types }

    describe '.fixed_fee' do
      subject { described_class.fixed_fee }

      it { is_expected.not_to be_empty }
      it { is_expected.to all(have_attributes(is_fixed_fee: true)) }
    end

    describe '.not_fixed_fee' do
      subject { described_class.not_fixed_fee }

      it { is_expected.not_to be_empty }
      it { is_expected.to all(have_attributes(is_fixed_fee: false)) }
    end

    describe '.requires_cracked_dates' do
      subject { described_class.requires_cracked_dates }

      it { is_expected.not_to be_empty }
      it { is_expected.to all(have_attributes(requires_cracked_dates: true)) }
    end

    describe '.requires_trial_dates' do
      subject { described_class.requires_trial_dates }

      it { is_expected.not_to be_empty }
      it { is_expected.to all(have_attributes(requires_trial_dates: true)) }
    end

    describe '.requires_retrial_dates' do
      subject { described_class.requires_retrial_dates }

      it { is_expected.not_to be_empty }
      it { is_expected.to all(have_attributes(requires_retrial_dates: true)) }
    end

    describe '.graduated_fees' do
      subject(:graduated_fees) { described_class.graduated_fees }

      before { create(:graduated_fee_type, :grtrl) }

      it { is_expected.not_to be_empty }
      it { expect(graduated_fees.map(&:fee_type_code)).to all(be_one_of(%w[GRCBR GRRAK GRDIS GRGLT GRRTR GRTRL])) }
    end

    describe '.trial_fees' do
      subject(:trial_fees) { described_class.trial_fees }

      it { is_expected.not_to be_empty }
      it { expect(trial_fees.map(&:fee_type_code)).to all(be_one_of(%w[GRCBR GRRAK GRRTR GRTRL])) }
    end
  end
end
