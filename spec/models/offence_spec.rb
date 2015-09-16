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

  describe '#as_json' do
    subject { create(:offence) }

    it 'should include the offence class as nested JSON' do
      expect(JSON.parse(subject.to_json)).to have_key('offence_class')
      expect(JSON.parse(subject.to_json)['offence_class']).to eq(JSON.parse(subject.offence_class.to_json))
    end
  end
end
