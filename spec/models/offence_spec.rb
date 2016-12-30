# == Schema Information
#
# Table name: offences
#
#  id               :integer          not null, primary key
#  description      :string
#  offence_class_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#

require 'rails_helper'

RSpec.describe Offence, type: :model do
  it { should have_many(:claims) }

  it { should validate_presence_of(:offence_class) }
  it { should validate_presence_of(:description) }

  describe '#offence_class_description' do
    it 'returns class letter and description' do
      offence_class = create :offence_class, class_letter: 'A', description: 'My offence class'
      offence = create :offence, offence_class: offence_class
      expect(offence.offence_class_description).to eq 'A: My offence class'
    end
  end
end
