require 'rails_helper'

RSpec.describe AssessmentPresenter do
  
  let(:claim)       { FactoryGirl.create :claim, apply_vat: true }
  
  context 'currency fields' do
    it 'should format currency amount' do
      claim.assessment.update_values(1452.33, 2455.77)
      presenter = AssessmentPresenter.new(claim.assessment, view)

      expect(presenter.fees_total).to eq '£1,452.33'
      expect(presenter.expenses_total).to eq '£2,455.77'
      expect(presenter.total).to eq '£3,908.10'
      expect(presenter.vat_amount).to eq '£683.92'
      expect(presenter.total_inc_vat).to eq '£4,592.02'
    end
  end

end
