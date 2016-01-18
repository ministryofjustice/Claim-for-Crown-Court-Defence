# == Schema Information
#
# Table name: certifications
#
#  id                               :integer          not null, primary key
#  claim_id                         :integer
#  certification_type_id            :integer
#  certified_by                     :string
#  certification_date               :date
#  created_at                       :datetime
#  updated_at                       :datetime
#

require 'rails_helper'

RSpec.describe Certification, type: :model do
  it { should belong_to(:claim) }
  it { should belong_to(:certification_type) }

  it { should validate_presence_of(:certification_type_id) }
  it { should validate_presence_of(:certified_by) }
  it { should validate_presence_of(:certification_date) }

  let!(:certification_type) { create(:certification_type) }
  subject { build(:certification, certification_type: certification_type) }

  context 'validations' do
    it 'should be invalid with no bools true' do
      [
       "main_hearing",
       "notified_court",
       "attended_pcmh",
       "attended_first_hearing",
       "previous_advocate_notified_court",
       "fixed_fee_case"
      ].each do |attribute|
        subject.attributes[attribute] = false
      end

      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to eq( ['You must select one option on this form'] )
    end
  end
end
