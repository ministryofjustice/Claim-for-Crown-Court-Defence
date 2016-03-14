# == Schema Information
#
# Table name: offence_classes
#
#  id           :integer          not null, primary key
#  class_letter :string
#  description  :string
#  created_at   :datetime
#  updated_at   :datetime
#

require 'rails_helper'

RSpec.describe OffenceClass, type: :model do
  it { should have_many(:offences) }

  it { should validate_presence_of(:class_letter) }
  it { should validate_uniqueness_of(:class_letter).with_message('Offence class letter must be unique') }
  #it { should validate_inclusion_of(:class_letter).in_array(('A'..'K').to_a) }  # flaky, random failures
  it { should validate_presence_of(:description) }

  subject { create(:offence_class, class_letter: 'A', description: 'lorem ipsum') }

  describe '#letter_and_description' do
    it 'returns the offence letter and description' do
      expect(subject.letter_and_description).to eq('A: lorem ipsum')
    end
  end

  describe '#to_s' do
    it 'returns the offence letter and description' do
      expect(subject.to_s).to eq('A: lorem ipsum')
    end
  end

  describe 'validation of class letters' do
    context 'letters A to K' do
      ('A'..'K').each do |letter|
        it "validates class_letter #{letter}" do
          subject.class_letter = letter
          expect(subject).to be_valid
        end
      end
    end

    context 'letters other than A to K' do
      it 'fails for letter L' do
        subject.class_letter = 'L'
        expect(subject).to be_invalid
      end
    end
  end
end
