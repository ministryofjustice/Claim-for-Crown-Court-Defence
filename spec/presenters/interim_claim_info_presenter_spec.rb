require 'rails_helper'

RSpec.describe InterimClaimInfoPresenter do
  let(:issued_date) { Date.new(2017, 12, 1) }
  let(:executed_date) { Date.new(2017, 12, 4) }
  let(:info) { build(:interim_claim_info, warrant_issued_date: issued_date, warrant_executed_date: executed_date) }

  subject(:presenter) { described_class.new(info, view) }

  describe '#warrant_issued_date' do
    specify { expect(presenter.warrant_issued_date).to eq('01/12/2017') }
  end

  describe '#warrant_executed_date' do
    specify { expect(presenter.warrant_executed_date).to eq('04/12/2017') }
  end
end
