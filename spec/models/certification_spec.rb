# == Schema Information
#
# Table name: certifications
#
#  id                    :integer          not null, primary key
#  claim_id              :integer
#  certified_by          :string
#  certification_date    :date
#  created_at            :datetime
#  updated_at            :datetime
#  certification_type_id :integer
#

require 'rails_helper'

RSpec.describe Certification, type: :model do
  it { should belong_to(:claim) }
  it { should belong_to(:certification_type) }

  it { should validate_presence_of(:certified_by) }
  it { should validate_presence_of(:certification_date) }

  let!(:certification_type) { create(:certification_type) }
  let(:claim) { build(:claim) }

  subject { build(:certification, certification_type: certification_type, claim: claim) }

  context 'validations' do
    it 'should be invalid without certification type' do
      subject.certification_type_id = nil
      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to eq(['You must select one option on this form'])
    end
  end
end
