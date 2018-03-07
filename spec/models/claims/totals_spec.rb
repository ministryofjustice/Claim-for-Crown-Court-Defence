require 'rails_helper'

RSpec.describe Claim, type: :model do
  subject(:claim) { create(:claim) }
  let(:expenses) { [3.5, 1.0, 142.0].each { |amount| create(:expense, claim_id: claim.id, amount: amount) } }
  let(:fee_type) { create(:fixed_fee_type) }

  context 'fees total' do
    describe '#calculate_fees_total' do
      it 'calculates the fees total' do
        expect(claim.calculate_fees_total).to eq(25.0)
      end
    end

    describe '#update_fees_total' do
      it 'stores the fees total' do
        expect(claim.fees_total).to eq(25.0)
      end

      it 'updates the fees total' do
        create(:fixed_fee, fee_type: fee_type, claim_id: claim.id, rate: 2.00)
        claim.reload
        expect(claim.fees_total).to eq(27.0)
      end

      it 'updates total when claim fee destroyed' do
        create(:fixed_fee, fee_type: fee_type, claim_id: claim.id, rate: 2.00)
        claim.fees.first.destroy
        claim.reload
        expect(claim.fees_total).to eq(2.0)
      end
    end
  end

  context 'expenses total' do
    before { expenses; claim.reload }

    describe '#calculate_expenses_total' do
      it 'calculates expenses total' do
        expect(claim.calculate_expenses_total).to eq(146.5)
      end
    end

    describe '#update_expenses_total' do
      it 'stores the expenses total' do
        expect(claim.expenses_total).to eq(146.5)
      end

      it 'updates the expenses total' do
        create(:expense, claim_id: claim.id, amount: 3)
        claim.reload
        expect(claim.expenses_total).to eq(149.5)
      end

      it 'updates expenses total when expense destroyed' do
        claim.expenses.first.destroy
        claim.reload
        expect(claim.expenses_total).to eq(143.0)
      end
    end
  end

  context 'expenses vat' do
    before do
      VatRate.delete_all
      create(:vat_rate, :for_2011_onward)
      [3.5, 1.0, 142.0].each do |amount|
        create(:expense, claim_id: claim.id, amount: amount, vat_amount: 2)
      end
      claim.reload
    end

    # before { claim.reload }

    context 'AGFS claim' do
      subject(:claim) { create(:claim) }

      it 'calculates the claim expenses VAT' do
        expect(claim.expenses_vat).to eq(29.3)
      end
    end

    context 'LGFS claim' do
      subject(:claim) { create(:litigator_claim, apply_vat: true) }

      it 'calculates the claim expenses VAT' do
        expect(claim.expenses_vat).to eq(6.0)
      end
    end
  end

  context 'total' do
    before { expenses; claim.reload }

    describe '#calculate_total' do
      it 'calculates the fees and expenses total' do
        create(:expense, claim_id: claim.id, amount: 3.0)
        claim.reload
        expect(claim.calculate_total).to eq(174.5)
      end
    end

    describe '#update_total' do
      it 'updates the total' do
        create(:expense, claim_id: claim.id, amount: 3)
        create(:fixed_fee, fee_type: fee_type, claim_id: claim.id, rate: 4.00)
        claim.reload
        expect(claim.total).to eq(178.5)
      end

      it 'updates total when expense/fee destroyed' do
        claim.expenses.first.destroy # 3.5
        claim.fees.first.destroy # 250.0
        claim.reload
        expect(claim.total).to eq(143.00)
      end
    end
  end

  context 'combined totals spec' do
    context 'LGFS' do
      context 'with VAT' do
        it 'should add totals and calculate VAT as and when submodels are added or removed' do
          claim = create :litigator_claim, :without_fees
          allow(claim).to receive(:vat_registered?).and_return(true)
          claim.apply_vat = true
          expect(claim.vat_registered?).to be true
          expect_totals_to_be(claim, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

          # add misc fees for 31.5, and 6.25 - VAT should be added in
          claim.fees << create(:misc_fee, rate: 10.5, quantity: 3)
          claim.fees << create(:misc_fee, rate: 6.25, quantity: 1)
          claim.save!
          expect_totals_to_be(claim, 0.0, 0.0, 37.75, 7.55, 0.0, 0.0) # VAT £6.61 calculated using the test VAT rate of 20.0%

          # add expenses for 9.99
          claim.expenses << create(:expense, amount: 9.99, vat_amount: 1.75)
          expect_totals_to_be(claim, 9.99, 2.0, 37.75, 7.55, 0.0, 0.0)

          # add disbursements for 55.33 & 100
          claim.disbursements << create(:disbursement, claim: claim, net_amount: 55.33, vat_amount: 9.68)
          claim.disbursements << create(:disbursement, claim: claim, net_amount: 100.0, vat_amount: 10.0)
          expect_totals_to_be(claim, 9.99, 2.0, 37.75, 7.55, 155.33, 19.68)

          # remove the fee for 31.5
          claim.fees.detect{ |f| f.amount == 31.5 }.destroy
          expect_totals_to_be(claim, 9.99, 2.0, 6.25, 1.25, 155.33, 19.68)

          # remove the disbursement for 100
          claim.disbursements.detect{ |d| d.net_amount == 100.0 }.destroy
          expect_totals_to_be(claim, 9.99, 2.0, 6.25, 1.25, 55.33, 9.68)

          claim.expenses.first.destroy
          expect_totals_to_be(claim, 0.0, 0.0, 6.25, 1.25, 55.33, 9.68)
        end
      end

      context 'without VAT' do
        it 'should add totals with explicit VAT amounts for expenses and disbursements as and when submodels are added or removed' do
          claim = create :litigator_claim, :without_fees
          allow(claim).to receive(:vat_registered?).and_return(false)
          claim.apply_vat = false
          expect_totals_to_be(claim, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

          # add misc fees for 31.5, and 6.25 - VAT should not be added in
          claim.fees << create(:misc_fee, rate: 10.5, quantity: 3)
          claim.fees << create(:misc_fee, rate: 6.25, quantity: 1)
          claim.save!
          expect_totals_to_be(claim, 0.0, 0.0, 37.75, 0.0, 0.0, 0.0)

          # add expenses for 9.99 with specific vat amount
          claim.expenses << create(:expense, claim: claim, amount: 9.99, vat_amount: 0.45)
          expect_totals_to_be(claim, 9.99, 0.45, 37.75, 0.0, 0.0, 0.0)

          # add disbursements for 55.33 & 100 with specific VAT amounts
          claim.disbursements << create(:disbursement, claim: claim, net_amount: 55.33, vat_amount: 2.35)
          claim.disbursements << create(:disbursement, claim: claim, net_amount: 100.0, vat_amount: 4.00)
          expect_totals_to_be(claim, 9.99, 0.45, 37.75, 0.0, 155.33, 6.35)
        end
      end
    end

    context 'AGFS' do
      context 'with VAT' do
        it 'should automatically add VAT' do
          claim = create :advocate_claim, :without_fees
          allow(claim).to receive(:vat_registered?).and_return(true)
          claim.apply_vat = true
          expect_totals_to_be(claim, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

          # add basic fee and VAT should be calculated and added in
          claim.basic_fees << create(:basic_fee, claim: claim, quantity: 1, rate: 200)
          expect_totals_to_be(claim, 0.0, 0.0, 200.0, 40.0, 0.0, 0.0) # VAT £35.00 calculated using the test VAT rate of 20.0%

          # add expense and VAT should be calculated and added in
          claim.expenses << create(:expense, claim: claim, amount: 9.99)
          expect_totals_to_be(claim, 9.99, 2.0, 200.0, 40.0, 0.0, 0.0)
        end
      end

      context 'without VAT' do
        it 'should not add VAT' do
          claim = create :advocate_claim, :without_fees
          claim.apply_vat = false
          allow(claim).to receive(:vat_registered?).and_return(false)

          expect_totals_to_be(claim, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

          # add basic fee and VAT should be calculated and added in
          claim.basic_fees << create(:basic_fee, claim: claim, quantity: 1, rate: 200)
          expect_totals_to_be(claim, 0.0, 0.0, 200.0, 0.0, 0.0, 0.0)

          # add expense and VAT should be calculated and added in
          claim.expenses << create(:expense, claim: claim, amount: 9.99)
          expect_totals_to_be(claim, 9.99, 0.0, 200.0, 0.0, 0.0, 0.0)
        end
      end
    end

    describe 'updating value bands and totals' do
      let(:claim) { create :litigator_claim }

      it 'updates the value band id when an added disbursement takes it to the next band' do
        expect(claim.total).to eq 25.0
        expect(claim.vat_amount).to eq 0.0
        expect(claim.value_band_id).to eq 10

        create :disbursement, claim: claim, net_amount: 25_000.0, vat_amount: 5_000.0

        claim.reload
        expect(claim.total).to eq 25_025.0
        expect(claim.vat_amount).to eq 5_000.0
        expect(claim.value_band_id).to eq 20
      end

      it 'updates the value band id when added expenses takes it to the next band' do
        expect(claim.total).to eq 25.0
        expect(claim.vat_amount).to eq 0.0
        expect(claim.value_band_id).to eq 10

        create :expense, claim: claim, amount: 25_002.20, vat_amount: 5_000.20

        claim.reload
        expect(claim.total).to eq 25_027.2
        expect(claim.vat_amount).to eq 5_000.20
        expect(claim.value_band_id).to eq 20
      end

      it 'updates the value band id when added fees takes it to the next band' do
        expect(claim.total).to eq 25.0
        expect(claim.vat_amount).to eq 0.0
        expect(claim.value_band_id).to eq 10

        create :misc_fee, claim: claim, amount: 25_002.20

        claim.reload
        expect(claim.total).to eq 25_027.2
        expect(claim.vat_amount).to eq 0.0
        expect(claim.value_band_id).to eq 20
      end
    end

    def expect_totals_to_be(claim, et, ev, ft, fv, dt, dv)
      expect(claim.expenses_total).to eq et
      expect(claim.expenses_vat).to eq ev
      expect(claim.fees_total).to eq ft
      expect(claim.fees_vat).to eq fv
      expect(claim.disbursements_total).to eq dt
      expect(claim.disbursements_vat).to eq dv
      expect(claim.total).to eq BigDecimal.new(et + ft + dt, 8)
      expect(claim.vat_amount).to eq BigDecimal.new(ev + fv + dv, 8)
    end
  end
end
