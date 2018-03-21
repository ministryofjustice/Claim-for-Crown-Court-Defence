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

  describe '#offence_class_description' do
    it 'returns class letter and description' do
      offence_class = create :offence_class, class_letter: 'A', description: 'My offence class'
      offence = create :offence, offence_class: offence_class
      expect(offence.offence_class_description).to eq 'A: My offence class'
    end
  end

  describe 'validations' do
    subject(:offence) { build :offence, offence_band: offence_band, offence_class: offence_class }
    let(:offence_band) { create :offence_band }
    let(:offence_class) { create :offence_class, class_letter: 'A', description: 'My offence class' }

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
end
