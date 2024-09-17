require 'rails_helper'

RSpec.describe Claim do
  subject(:claim) { create(:advocate_claim, :with_fixed_fee_case) }

  let(:expenses) { [3.5, 1.0, 142.0].each { |amount| create(:expense, claim_id: claim.id, amount:) } }
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
        create(:fixed_fee, fee_type:, claim_id: claim.id, rate: 2.00)
        claim.reload
        expect(claim.fees_total).to eq(27.0)
      end

      it 'updates total when claim fee destroyed' do
        create(:fixed_fee, fee_type:, claim_id: claim.id, rate: 2.00)
        claim.fees.first.destroy
        claim.reload
        expect(claim.fees_total).to eq(2.0)
      end
    end
  end

  context 'expenses total' do
    before do
      expenses
      claim.reload
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
        create(:expense, claim_id: claim.id, amount:, vat_amount: 2)
      end
      claim.reload
    end

    context 'AGFS claim' do
      subject(:claim) { create(:advocate_claim) }

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
    before do
      expenses
      claim.reload
    end

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
        create(:fixed_fee, fee_type:, claim_id: claim.id, rate: 4.00)
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
    subject(:claim) { create(:litigator_claim, :without_fees) }

    context 'LGFS' do
      context 'with VAT' do
        before { allow(claim).to receive_messages(vat_registered?: true, apply_vat: true) }

        it 'adds totals and calculate VAT as and when submodels are added or removed' do
          is_expected.to have_totals(fees_total: 0.0, fees_vat: 0.0, disbursements_total: 0.0, disbursements_vat: 0.0, expenses_total: 0.0, expenses_vat: 0.0)

          # add misc fees for 31.5, and 6.25 - VAT should be added in
          claim.fees << create(:misc_fee, rate: 10.5, quantity: 3)
          claim.fees << create(:misc_fee, rate: 6.25, quantity: 1)
          claim.save!
          is_expected.to have_totals(fees_total: 37.75, fees_vat: 7.55, disbursements_total: 0.0, disbursements_vat: 0.0, expenses_total: 0.0, expenses_vat: 0.0)

          # add expenses for 9.99
          claim.expenses << create(:expense, amount: 9.99, vat_amount: 1.75)
          is_expected.to have_totals(fees_total: 37.75, fees_vat: 7.55, disbursements_total: 0.0, disbursements_vat: 0.0, expenses_total: 9.99, expenses_vat: 2.0)

          # add disbursements for 55.33 & 100
          claim.disbursements << create(:disbursement, claim:, net_amount: 55.33, vat_amount: 9.68)
          claim.disbursements << create(:disbursement, claim:, net_amount: 100.0, vat_amount: 10.0)
          is_expected.to have_totals(fees_total: 37.75, fees_vat: 7.55, disbursements_total: 155.33, disbursements_vat: 19.68, expenses_total: 9.99, expenses_vat: 2.0)

          # remove the fee for 31.5
          claim.fees.detect { |f| f.amount == BigDecimal(31.5) }.destroy
          is_expected.to have_totals(fees_total: 6.25, fees_vat: 1.25, disbursements_total: 155.33, disbursements_vat: 19.68, expenses_total: 9.99, expenses_vat: 2.0)

          # remove the disbursement for 100
          claim.disbursements.detect { |d| d.net_amount == BigDecimal(100.0) }.destroy
          is_expected.to have_totals(fees_total: 6.25, fees_vat: 1.25, disbursements_total: 55.33, disbursements_vat: 9.68, expenses_total: 9.99, expenses_vat: 2.0)

          claim.expenses.first.destroy
          is_expected.to have_totals(fees_total: 6.25, fees_vat: 1.25, disbursements_total: 55.33, disbursements_vat: 9.68, expenses_total: 0.0, expenses_vat: 0.0)
        end
      end

      context 'without VAT' do
        before { allow(claim).to receive_messages(vat_registered?: false, apply_vat?: false) }

        it 'adds totals with explicit VAT amounts for expenses and disbursements as and when submodels are added or removed' do
          is_expected.to have_totals(fees_total: 0.0, fees_vat: 0.0, disbursements_total: 0.0, disbursements_vat: 0.0, expenses_total: 0.0, expenses_vat: 0.0)

          # add misc fees for 31.5, and 6.25 - VAT should not be added in
          claim.fees << create(:misc_fee, rate: 10.5, quantity: 3)
          claim.fees << create(:misc_fee, rate: 6.25, quantity: 1)
          claim.save!
          is_expected.to have_totals(fees_total: 37.75, fees_vat: 0.0, disbursements_total: 0.0, disbursements_vat: 0.0, expenses_total: 0.0, expenses_vat: 0.0)

          # add expenses for 9.99 with specific vat amount
          claim.expenses << create(:expense, claim:, amount: 9.99, vat_amount: 0.45)
          is_expected.to have_totals(fees_total: 37.75, fees_vat: 0.0, disbursements_total: 0.0, disbursements_vat: 0.0, expenses_total: 9.99, expenses_vat: 0.45)

          # add disbursements for 55.33 & 100 with specific VAT amounts
          claim.disbursements << create(:disbursement, claim:, net_amount: 55.33, vat_amount: 2.35)
          claim.disbursements << create(:disbursement, claim:, net_amount: 100.0, vat_amount: 4.00)
          is_expected.to have_totals(fees_total: 37.75, fees_vat: 0.0, disbursements_total: 155.33, disbursements_vat: 6.35, expenses_total: 9.99, expenses_vat: 0.45)
        end
      end
    end

    context 'AGFS' do
      subject(:claim) { create(:advocate_claim, :without_fees) }

      context 'with VAT' do
        before do
          allow(claim).to receive_messages(vat_registered?: true, apply_vat?: true)
          create(:basic_fee, claim:, quantity: 1, rate: 200)
          create(:expense, claim:, amount: 9.99)
        end

        it 'automatically applies VAT' do
          is_expected.to have_totals(fees_total: 200.0, fees_vat: 40.0, disbursements_total: 0.0, disbursements_vat: 0.0, expenses_total: 9.99, expenses_vat: 2.0)
        end
      end

      context 'without VAT' do
        before do
          allow(claim).to receive_messages(vat_registered?: false, apply_vat?: false)
        end

        context 'with no fees, expenses or disbursements' do
          it 'has zero totals and vat' do
            is_expected.to have_totals(fees_total: 0.00, fees_vat: 0.0, disbursements_total: 0.0, disbursements_vat: 0.0, expenses_total: 0.0, expenses_vat: 0.0)
          end
        end

        context 'with fees and expenses' do
          before do
            create(:basic_fee, claim:, quantity: 1, rate: 200)
            create(:misc_fee, claim:, quantity: 2, rate: 50)
            create(:expense, claim:, amount: 9.99)
          end

          it 'applies no VAT' do
            is_expected.to have_totals(fees_total: 300.00, fees_vat: 0.0, disbursements_total: 0.0, disbursements_vat: 0.0, expenses_total: 9.99, expenses_vat: 0.0)
          end
        end
      end

      # This recreates a bug found on expenses for api claim
      # submissions by non-vat-registered suppliers/providers
      # with apply_vat=true whereby expenses were not VAT'd.
      context 'with apply_vat flag set to true on a non-VAT registered provider' do
        before do
          allow(claim).to receive_messages(vat_registered?: false, apply_vat?: true)
        end

        context 'with fees and expenses' do
          before do
            create(:basic_fee, claim:, quantity: 1, rate: 200)
            create(:misc_fee, claim:, quantity: 2, rate: 50)
            create(:expense, claim:, amount: 9.99)
          end

          it 'automatically adds VAT' do
            is_expected.to have_totals(fees_total: 300.0, fees_vat: 60.0, disbursements_total: 0.0, disbursements_vat: 0.0, expenses_total: 9.99, expenses_vat: 2.0)
          end
        end
      end
    end

    describe 'updating value bands and totals' do
      let(:claim) { create(:litigator_claim) }

      context 'with a disbursment' do
        let(:new_fee) { create(:disbursement, claim:, net_amount: 30_000.0, vat_amount: 5_000.0) }

        it { expect { new_fee }.to change(claim, :total).by(30_000) }
        it { expect { new_fee }.to change(claim, :vat_amount).by(5_000) }
        it { expect { new_fee }.to change { claim.reload.value_band_id }.from(10).to(20) }
      end

      context 'with an expense' do
        let(:new_fee) { create(:expense, claim:, amount: 25_002.2, vat_amount: 5_000.2) }

        it { expect { new_fee }.to change(claim, :total).by(25_002.2) }
        it { expect { new_fee }.to change(claim, :vat_amount).by(5_000.2) }
        it { expect { new_fee }.to change { claim.reload.value_band_id }.from(10).to(20) }
      end

      context 'with a misc fee' do
        # NOTE: the special prep fee, mispf, is used here as it is
        # as an edge case because it is calculated for agfs but not for lgfs
        let(:new_fee) { create(:misc_fee, :mispf_fee, claim:, amount: 30_002.2) }

        it { expect { new_fee }.to change(claim, :total).by(30_002.2) }
        it { expect { new_fee }.not_to change(claim, :vat_amount) }
        it { expect { new_fee }.to change { claim.reload.value_band_id }.from(10).to(20) }
      end
    end
  end
end
