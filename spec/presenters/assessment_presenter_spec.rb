require 'rails_helper'

RSpec.describe AssessmentPresenter do
  let(:claim) { FactoryBot.create :claim, apply_vat: true }
  let(:presenter) { AssessmentPresenter.new(claim.assessment, view) }

  context 'currency fields' do
    let(:currency_pattern) { /£\d,\d{3}\.\d{2}/ }

    before { claim.assessment.update_values(1452.33, 2455.77, 1505.24) }

    it 'totals formatted as currency' do
      expect(presenter.fees_total).to match currency_pattern
      expect(presenter.expenses_total).to match currency_pattern
      expect(presenter.disbursements_total).to match currency_pattern
      expect(presenter.total).to match currency_pattern
      expect(presenter.vat_amount).to match currency_pattern
      expect(presenter.total_inc_vat).to match currency_pattern
    end
  end

end
