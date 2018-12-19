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
  subject(:certification) { build(:certification, certification_type: certification_type, claim: claim) }
  let!(:certification_type) { create(:certification_type) }
  let(:claim) { build(:claim) }

  it { is_expected.to belong_to(:claim) }
  it { is_expected.to belong_to(:certification_type) }

  it { is_expected.to validate_presence_of(:certified_by) }
  it { is_expected.to validate_presence_of(:certification_date) }

  context 'validations' do
    it 'should be invalid without certification type' do
      certification.certification_type_id = nil
      expect(certification).to be_invalid
      expect(certification.errors.full_messages).to include('You must select one option on this form')
    end

    context 'certification date' do
      context 'when is before the claim creation date' do
        let(:claim) { build(:claim, created_at: 2.days.ago) }

        before do
          certification.certification_date = 3.days.ago
        end

        it 'should be invalid' do
          expect(certification).to be_invalid
          expect(certification.errors.full_messages).to include('Certification date must be same day or after claim submission day')
        end
      end

      context 'when is in the future' do
        before do
          certification.certification_date = 10.days.from_now
        end

        it 'should be invalid' do
          expect(certification).to be_invalid
          expect(certification.errors.full_messages).to include("Certification date can't be in the future")
        end
      end
    end
  end
end
