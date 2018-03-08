require 'rails_helper'

describe RedeterminationPresenter do
  let(:claim) { create :claim, apply_vat: true }
  let(:rd) { create :redetermination, fees: 1452.33, expenses: 2455.77, disbursements: 2123.55, claim: claim }
  let(:presenter) { RedeterminationPresenter.new(rd, view) }

  context 'currency fields' do
    let(:currency_pattern) { /£\d,\d{3}\.\d{2}/ }

    it 'totals formatted as currency' do
      expect(presenter.fees_total).to match currency_pattern
      expect(presenter.expenses_total).to match currency_pattern
      expect(presenter.disbursements_total).to match currency_pattern
      expect(presenter.total).to match currency_pattern
      expect(presenter.vat_amount).to match currency_pattern
      expect(presenter.total_inc_vat).to match currency_pattern
    end
  end

  context 'when VAT amount is nil' do
    before { allow(rd).to receive(:vat_amount).and_return(nil) }

    it 'should still calculate' do
      expect(presenter.total_inc_vat).to eq '£6,031.65'
    end
  end
end
