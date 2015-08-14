require 'rails_helper'


describe Assessment do

  let(:claim)         { FactoryGirl.create :claim }

  context 'validations' do

    context 'fees' do

      it 'should not accept negative values'  do
        expect {
          # FactoryGirl.create :assessment, claim: claim, fees: -33.55
          claim.assessment.update!(fees: -33.35)
        }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Fees Assessed fees must be greater than or equal to zero'
      end

      it 'should not accept nil values ' do
        expect {
          claim.assessment.update!(fees: nil)
          claim.assessment.save!
        }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Fees Assessed fees must be greater than or equal to zero'
      end
    end

    context 'expenses' do

      it 'should not accept negative values'  do
        expect {
          claim.assessment.update!(expenses: -33.55)
        }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Expenses Assessed expenses must be greater than or equal to zero'
      end

      it 'should not accept nil values ' do
        expect {
          claim.assessment.update!(expenses: nil)
        }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Expenses Assessed expenses must be greater than or equal to zero'
      end
    end
  end



  context 'automatic calculation of total' do
    it 'should calculate the total on save' do
      ass = FactoryGirl.create :assessment
      expect(ass.total).to eq(ass.fees + ass.expenses)
    end
  end

  context '#zeroize!' do
    it 'should zeroize values and save' do
      assessment = FactoryGirl.create :assessment
      expect(assessment.fees).not_to eq 0
      expect(assessment.expenses).not_to eq 0
      expect(assessment.total).not_to eq 0
      assessment.zeroize!

      reloaded_assessment = Assessment.find assessment.id
      expect(reloaded_assessment.fees).to eq 0
      expect(reloaded_assessment.expenses).to eq 0
      expect(reloaded_assessment.total).to eq 0
    end
  end

end