# == Schema Information
#
# Table name: determinations
#
#  id            :integer          not null, primary key
#  claim_id      :integer
#  type          :string
#  fees          :decimal(, )      default(0.0)
#  expenses      :decimal(, )      default(0.0)
#  total         :decimal(, )
#  created_at    :datetime
#  updated_at    :datetime
#  vat_amount    :float            default(0.0)
#  disbursements :decimal(, )      default(0.0)
#

require 'rails_helper'


describe Assessment do

  let(:claim)         { FactoryGirl.create :claim }

  context 'validations' do

    context 'fees' do
      it 'should not accept negative values'  do
        expect {
          # FactoryGirl.create :assessment, claim: claim, fees: -33.55
          claim.assessment.update!(fees: -33.35)
        }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Assessed fees must be greater than or equal to zero'
      end

      it 'should not accept nil values ' do
        expect {
          claim.assessment.update!(fees: nil)
          claim.assessment.save!
        }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Assessed fees must be greater than or equal to zero'
      end
    end

    context 'expenses' do
      it 'should not accept negative values'  do
        expect {
          claim.assessment.update!(expenses: -33.55)
        }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Assessed expenses must be greater than or equal to zero'
      end

      it 'should not accept nil values ' do
        expect {
          claim.assessment.update!(expenses: nil)
        }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Assessed expenses must be greater than or equal to zero'
      end
    end

    context 'disbursements' do
      it 'should not accept negative values' do
        expect {
          claim.assessment.update!(disbursements: -33.55)
        }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Assessed disbursements must be greater than or equal to zero'
      end

      it 'should not accept nil values ' do
        expect {
          claim.assessment.update!(disbursements: nil)
        }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Assessed disbursements must be greater than or equal to zero'
      end
    end
  end

  context 'automatic calculation of total' do
    it 'should calculate the total on save' do
      ass = FactoryGirl.create :assessment
      expect(ass.total).to eq(ass.fees + ass.expenses + ass.disbursements)
    end
  end

  context '#calculate_vat' do
    context 'advocate claims' do
      it 'should automatically calculate the vat amount based on the total assessed and the claim vat_date' do
        claim = FactoryGirl.create :advocate_claim, apply_vat: true
        ass = claim.assessment
        ass.update_values(100.0, 250.0, 0)
        expect(ass.vat_amount).to eq((ass.total * 0.175).round(2))
      end
    end

    context 'litigator claims' do
      it 'should not automatically calculate the VAT amount, instead using manually input vat_amount' do
        claim = FactoryGirl.create :litigator_claim, apply_vat: true
        ass = claim.assessment
        ass.vat_amount = 0.33
        ass.update_values(100.0, 250.0, 150.0)
        expect(ass.vat_amount).to eql((0.33))
      end
    end
  end

  context '#zeroize!' do
    it 'should zeroize values and save' do
      assessment = FactoryGirl.create :assessment
      expect(assessment.fees).not_to eq 0
      expect(assessment.expenses).not_to eq 0
      expect(assessment.disbursements).not_to eq 0
      expect(assessment.total).not_to eq 0
      assessment.zeroize!

      reloaded_assessment = Assessment.find assessment.id
      expect(reloaded_assessment.fees).to eq 0
      expect(reloaded_assessment.expenses).to eq 0
      expect(reloaded_assessment.disbursements).to eq 0
      expect(reloaded_assessment.total).to eq 0
    end
  end

  describe '.update' do
    it 'should raise error if assessment not blank' do
      assessment = create :assessment
      expect {
        assessment.update_values(100.00, 200.22, 150.00, DateTime.new(2016, 1, 2, 3, 4, 5))
      }.to raise_error RuntimeError, "Cannot update a non-blank assessment"
    end

    it 'should update the fields' do
      assessment = create :assessment, :blank
      assessment.update_values(888.88, 333.33, 150.00, DateTime.new(2016, 1, 2, 3, 4, 5))
      assessment.reload
      expect(assessment.fees).to eq 888.88
      expect(assessment.expenses).to eq 333.33
      expect(assessment.disbursements).to eq 150.00
      expect(assessment.created_at).to eq DateTime.new(2016, 1, 2, 3, 4, 5)
    end
  end

end
