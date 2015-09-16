# == Schema Information
#
# Table name: certifications
#
#  id                               :integer          not null, primary key
#  claim_id                         :integer
#  main_hearing                     :boolean
#  notified_court                   :boolean
#  attended_pcmh                    :boolean
#  attended_first_hearing           :boolean
#  previous_advocate_notified_court :boolean
#  fixed_fee_case                   :boolean
#  certified_by                     :string
#  certification_date               :date
#  created_at                       :datetime
#  updated_at                       :datetime
#

require 'rails_helper'

RSpec.describe Certification, type: :model do
  
  let(:cert)          { FactoryGirl.build :certification }

  context 'validations' do
    it 'should be valid with only one bool true' do
      expect(cert).to be_valid
    end

    it 'should be invalid with no bools true' do
      cert.main_hearing = false
      expect(cert).not_to be_valid
      expect(cert.errors.full_messages).to eq( ['You must check one and only one checkbox on this form'] )
    end

    it 'should be invalid with multiple bools true' do
      cert.fixed_fee_case = true
      expect(cert).not_to be_valid
      expect(cert.errors.full_messages).to eq( ['You must check one and only one checkbox on this form'] )
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
