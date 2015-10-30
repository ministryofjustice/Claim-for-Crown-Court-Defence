require 'rails_helper'

RSpec.describe AssessmentPresenter do
  
  let(:assessment)  { FactoryGirl.create :assessment, fees: 1452.33, expenses: 2455.77 }
  let(:subject)     { AssessmentPresenter.new(assessment, view) }
  
  context 'currency fields' do
  
    it 'should format currency amount' do
      expect(subject.fees_total).to eq '£1,452.33'
      expect(subject.expenses_total).to eq '£2,455.77'
      expect(subject.total).to eq '£3,908.10'
    end
  end

end
