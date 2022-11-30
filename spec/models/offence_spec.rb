# == Schema Information
#
# Table name: offences
#
#  id               :integer          not null, primary key
#  description      :string
#  offence_class_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#  unique_code      :string           default("anyoldrubbish"), not null
#

require 'rails_helper'

RSpec.describe Offence, type: :model do
  it { should have_many(:claims) }

  it { should validate_presence_of(:offence_class) }
  it { should validate_presence_of(:offence_band) }
  it { should validate_presence_of(:unique_code) }
  it { should validate_uniqueness_of(:unique_code) }
  it { should validate_presence_of(:description) }

  it 'can be queried by fee scheme types' do
    expect(described_class).to \
      respond_to(
        :in_scheme_nine,
        :in_scheme_9,
        :in_scheme_ten,
        :in_scheme_10,
        :in_scheme_eleven,
        :in_scheme_11,
        :in_scheme_twelve,
        :in_scheme_12,
        :in_scheme_thirteen,
        :in_scheme_13,
        :in_lgfs_scheme_10
      )
  end

  describe '#offence_class_description' do
    it 'returns class letter and description' do
      offence_class = create(:offence_class, class_letter: 'A', description: 'My offence class')
      offence = create(:offence, offence_class:)
      expect(offence.offence_class_description).to eq 'A: My offence class'
    end
  end

  describe 'validations' do
    subject(:offence) { build(:offence, offence_band:, offence_class:) }

    let(:offence_band) { create(:offence_band) }
    let(:offence_class) { create(:offence_class, class_letter: 'A', description: 'My offence class') }

    context 'when the offence has a offence_band' do
      let(:offence_class) { nil }

      it { is_expected.to be_valid }
    end

    context 'when the offence has an offence_class' do
      let(:offence_band) { nil }

      it { is_expected.to be_valid }
    end

    context 'when the offence has both a offence_band and an offence_class' do
      it { is_expected.to_not be_valid }
    end

    context 'when the offence has neither a offence_band and an offence_class' do
      let(:offence_band) { nil }
      let(:offence_class) { nil }

      it { is_expected.to_not be_valid }
    end
  end

  describe '#scheme_nine?' do
    subject { offence.scheme_nine? }

    context 'when the fee_scheme is set to ten' do
      let(:offence) { create(:offence, :with_fee_scheme_ten) }

      it { is_expected.to be_falsey }
    end

    context 'when the fee_scheme is set to nine' do
      let(:offence) { create(:offence, :with_fee_scheme) }

      it { is_expected.to be_truthy }
    end
  end

  describe '#scheme_ten?' do
    subject { offence.scheme_ten? }

    context 'when the fee_scheme is set to ten' do
      let(:offence) { create(:offence, :with_fee_scheme_ten) }

      it { is_expected.to be_truthy }
    end

    context 'when the fee_scheme is set to nine' do
      let(:offence) { create(:offence, :with_fee_scheme) }

      it { is_expected.to be_falsey }
    end
  end

  describe '#scheme_eleven?' do
    subject { offence.scheme_eleven? }

    context 'when the fee_scheme is set to eleven' do
      let(:offence) { create(:offence, :with_fee_scheme_eleven) }

      it { is_expected.to be_truthy }
    end

    context 'when the fee_scheme is set to nine' do
      let(:offence) { create(:offence, :with_fee_scheme) }

      it { is_expected.to be_falsey }
    end
  end

  describe '#post_agfs_reform?' do
    subject { offence.post_agfs_reform? }

    context 'when the fee_scheme is set to eleven' do
      let(:offence) { create(:offence, :with_fee_scheme_eleven) }

      it { is_expected.to be_truthy }
    end

    context 'when the fee_scheme is set to ten' do
      let(:offence) { create(:offence, :with_fee_scheme_ten) }

      it { is_expected.to be_truthy }
    end

    context 'when the fee_scheme is set to nine' do
      let(:offence) { create(:offence, :with_fee_scheme) }

      it { is_expected.to be_falsey }
    end
  end

  describe '#scheme_twelve?' do
    subject { offence.scheme_twelve? }

    context 'when the fee_scheme is set to nine' do
      let(:offence) { create(:offence, :with_fee_scheme) }

      it { is_expected.to be_falsey }
    end

    context 'when the fee_scheme is set to eleven' do
      let(:offence) { create(:offence, :with_fee_scheme_eleven) }

      it { is_expected.to be_falsey }
    end

    context 'when the fee_scheme is set to twelve' do
      let(:offence) { create(:offence, :with_fee_scheme_twelve) }

      it { is_expected.to be_truthy }
    end
  end

  describe '#scheme_thirteen?' do
    subject { offence.scheme_thirteen? }

    context 'when the fee_scheme is set to nine' do
      let(:offence) { create(:offence, :with_fee_scheme) }

      it { is_expected.to be_falsey }
    end

    context 'when the fee_scheme is set to eleven' do
      let(:offence) { create(:offence, :with_fee_scheme_eleven) }

      it { is_expected.to be_falsey }
    end

    context 'when the fee_scheme is set to twelve' do
      let(:offence) { create(:offence, :with_fee_scheme_twelve) }

      it { is_expected.to be_falsey }
    end

    context 'when the fee_scheme is set to thirteen' do
      let(:offence) { create(:offence, :with_fee_scheme_thirteen) }

      it { is_expected.to be_truthy }
    end
  end

  describe '#lgfs_scheme_ten?' do
    subject { offence.lgfs_scheme_ten? }

    context 'when the fee_scheme is set to nine' do
      let(:offence) { create(:offence, :with_fee_scheme) }

      it { is_expected.to be_falsey }
    end

    context 'when the fee_scheme is set to ten' do
      let(:offence) { create(:offence, :with_lgfs_fee_scheme_ten) }

      it { is_expected.to be_truthy }
    end
  end
end
