# == Schema Information
#
# Table name: case_types
#
#  id                      :integer          not null, primary key
#  name                    :string
#  is_fixed_fee            :boolean
#  created_at              :datetime
#  updated_at              :datetime
#  requires_cracked_dates  :boolean
#  requires_trial_dates    :boolean
#  allow_pcmh_fee_type     :boolean          default(FALSE)
#  requires_maat_reference :boolean          default(FALSE)
#  requires_retrial_dates  :boolean          default(FALSE)
#  roles                   :string
#  fee_type_code           :string
#

require 'rails_helper'

describe CaseType do

  it_behaves_like 'roles', CaseType, CaseType::ROLES

  after(:all) do
    clean_database
  end

  describe 'graduated_fee_type' do
    let!(:grad_fee_type)     { create :graduated_fee_type, code: 'GRAD' }
    let(:grad_case_type)    { build :case_type, fee_type_code: 'GRAD' }
    let(:grad_case_type_x)  { build :case_type, fee_type_code: 'XXXX' }
    let(:fixed_case_type)   { build :case_type, fee_type_code: nil }

    it 'returns nil if no fee_type_code' do
      expect(fixed_case_type.graduated_fee_type).to be_nil
    end

    it 'returns the appropriate graduated fee' do
      expect(grad_case_type.graduated_fee_type).to eq grad_fee_type
    end

    it 'returns nil if the code doesnt exist' do
      expect(grad_case_type_x.graduated_fee_type).to be_nil
    end
  end

  describe 'fixed_fee_type' do
    let!(:fixed_fee_type)     { create :fixed_fee_type, code: 'FIXED' }
    let(:fixed_case_type)    { build :case_type, fee_type_code: 'FIXED' }
    let(:fixed_case_type_x)  { build :case_type, fee_type_code: 'XXXX' }
    let(:grad_case_type)   { build :case_type, fee_type_code: nil }

    it 'returns nil if no fee_type_code' do
      expect(grad_case_type.fixed_fee_type).to be_nil
    end

    it 'returns the appropriate fixed fee' do
      expect(fixed_case_type.fixed_fee_type).to eq fixed_fee_type
    end

    it 'returns nil if the code doesnt exist' do
      expect(fixed_case_type_x.fixed_fee_type).to be_nil
    end
  end
end
