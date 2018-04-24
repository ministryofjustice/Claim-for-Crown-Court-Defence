require 'rails_helper'

module Stats
  describe SchemeTenReport do
    subject(:main) { described_class.new }

    it { is_expected.to be_a SchemeTenReport }

    describe 'validations' do
      subject(:valid) { main.valid? }

      before { main.report_date = new_date }

      context 'when the date is yesterday' do
        let(:new_date) { Date.yesterday }

        it { is_expected.to be true }
      end

      context 'when the date is today' do
        let(:new_date) { Date.today }

        it { is_expected.to be false }
      end

      context 'when the date is tomorrow' do
        let(:new_date) { Date.tomorrow }

        it { is_expected.to be false }
      end
    end
  end
end
