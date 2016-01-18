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

  let(:cert)          { FactoryGirl.build :certification }

  context 'validations' do
    it 'should be valid with only one certification type' do
      expect(cert).to be_valid
    end

    it 'should be invalid with no bools true' do
      cert.certification_type_id = ''
      expect(cert).not_to be_valid
      expect(cert.errors.full_messages).to eq( ['You must select one option on this form'] )
    end

    @wip
    it 'should be invalid with invalid id' do
      cert.certification_type_id = 999
      expect(cert).not_to be_valid
      expect(cert.errors.full_messages).to eq( ['You must select one option on this form'] )
    end

    it 'should be invalid if certified by is emtpy' do
      cert.certified_by = ''
      expect(cert).not_to be_valid
      expect(cert.errors.full_messages).to eq( ["Certified by cannot be blank"] )
    end

    it 'should be invalid if certification date is nil' do
      cert.certification_date = nil
      expect(cert).not_to be_valid
      expect(cert.errors.full_messages).to eq( ["Certification date cannot be blank"] )
    end
  end


end
