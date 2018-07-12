require 'rails_helper'

RSpec.describe Fee::BaseFeePresenter, type: :presenter do
  let(:claim) { build(:litigator_claim) }
  let(:fee) { build(:fixed_fee, claim: claim) }

  subject(:presenter) { described_class.new(fee, view) }

  describe '#display_amount?' do
    it { expect(presenter.display_amount?).to be_truthy }
  end
end
