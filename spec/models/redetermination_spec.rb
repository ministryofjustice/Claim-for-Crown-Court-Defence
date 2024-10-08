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

RSpec.describe Redetermination do
  let(:claim) { create(:claim) }

  describe '#create' do
    subject { described_class.create(claim:, **params) }

    include_examples 'numeric fields in determinations'
  end

  context 'automatic calculation of total' do
    it 'calculates the total on save' do
      rd = create(:redetermination)
      expect(rd.total).to eq(rd.fees + rd.expenses + rd.disbursements)
    end
  end

  context 'automatic calculation of VAT' do
    RSpec.shared_examples 'calculates redetermination VAT' do
      let(:redetermination) { build(:redetermination, fees: 100, expenses: 100, disbursements: 200, claim:) }

      it 'determines rate using VatRate model' do
        expect(VatRate).to receive(:vat_amount).at_least(:once).and_call_original
        redetermination.save
      end

      it 'updates determination\'s vat_amount' do
        expect { redetermination.save }.to change(redetermination, :vat_amount).from(0).to(80)
      end
    end

    describe '#calculate_vat' do
      context 'advocate claims' do
        let(:claim) { create(:advocate_claim, apply_vat: true) }

        include_examples 'calculates redetermination VAT'
      end

      context 'advocate supplementary claims' do
        let(:claim) { create(:advocate_supplementary_claim, apply_vat: true) }

        include_examples 'calculates redetermination VAT'
      end

      context 'advocate interim claims' do
        let(:claim) { create(:advocate_interim_claim, apply_vat: true) }

        include_examples 'calculates redetermination VAT'
      end

      context 'litigator claims' do
        let(:claim) { create(:litigator_claim, apply_vat: true) }
        let(:redetermination) { build(:redetermination, fees: 100.0, expenses: 0, disbursements: 0, claim:) }

        it 'does not update/calculate the VAT amount' do
          expect { redetermination.save }.not_to change(redetermination, :vat_amount)
        end
      end
    end
  end

  context 'default scope' do
    it 'returns the redeterminations in order of creation date' do
      date_1 = 2.months.ago
      date_2 = 1.month.ago
      date_3 = 1.week.ago

      # Given a number of redeterminations written at various times
      [date_3, date_1, date_2].each do |date|
        travel_to(date) do
          create(:redetermination, claim:)
        end
      end
      # when I call claim.redeterminations
      rds = claim.redeterminations

      # it should return them in created_at order - convert to integer to remove precesion pproblems on travis
      expect(rds.map { |rd| rd.created_at.to_i }).to eq([date_1.to_i, date_2.to_i, date_3.to_i])
    end
  end
end
