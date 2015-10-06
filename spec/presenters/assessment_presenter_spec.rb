require 'rails_helper'

describe AssessmentPresenter do
  
  let(:assessment)              { FactoryGirl.create :assessment, fees: 1452.33, expenses: 2455.77 }
  let(:presenter)               { AssessmentPresenter.new(assessment, view) }
  
  context 'currency fields' do
  
    it 'should format currency amount' do
      expect(presenter.fees_total).to eq '£1,452.33'
      expect(presenter.expenses_total).to eq '£2,455.77'
      expect(presenter.total).to eq '£3,908.10'
    end
  end

end
