require 'rails_helper'

RSpec.describe Claims::FinancialSummary, type: :model do
  # Uses default VAT rate factory (implicitly) with VAT rate of 17.5%

  context 'by advocate' do

    # TODO should not rely on values in factory which may change
    let!(:submitted_claim)  { create(:submitted_claim,) }
    let!(:allocated_claim)  { create(:allocated_claim,) }

    let!(:old_part_authorised_claim) do
      Timecop.freeze(Time.now - 2.week) do
        claim = create(:part_authorised_claim)
        Timecop.freeze(Time.now + 1.week) do
          claim.determinations.first.update(fees: claim.fees_total/2, expenses: claim.expenses_total)
          claim
        end
      end
    end

    let!(:part_authorised_claim) do
      Timecop.freeze(Time.now - 2.week) do
        claim = create(:part_authorised_claim)
        Timecop.freeze(Time.now + 2.week) do
          claim.determinations.first.update(fees: claim.fees_total/2, expenses: claim.expenses_total)
          claim
        end
      end
    end

    let!(:authorised_claim) do
      claim = create(:authorised_claim)
      claim.assessment.update_values!(claim.fees_total, claim.expenses_total)
      claim
    end

    let(:advocate_with_vat)           { create(:external_user, :advocate, vat_registered: true) }
    let(:advocate_without_vat)        { create(:external_user, :advocate, vat_registered: false) }
    let(:another_advocate)            { create(:external_user, :advocate) }
    let(:other_advocate_claim)        { create(:claim) }

    context 'with VAT applied' do
      before do
        [submitted_claim, allocated_claim, part_authorised_claim, authorised_claim, old_part_authorised_claim].each do |claim|
          claim.external_user = advocate_with_vat
          claim.creator = advocate_with_vat
          claim.save!
        end

        other_advocate_claim.external_user = another_advocate
        other_advocate_claim.creator = another_advocate
      end

      let(:summary)           { Claims::FinancialSummary.new(advocate_with_vat) }

      describe '#total_outstanding_claim_value' do
        it 'calculates the value of outstanding claims' do
          expect(summary.total_outstanding_claim_value).to eq(submitted_claim.total + submitted_claim.vat_amount + allocated_claim.total + allocated_claim.vat_amount)
        end
      end

      describe '#total_authorised_claim_value' do
        before do
          part_authorised_claim.external_user = advocate_with_vat
          part_authorised_claim.save!
        end

        it 'calculates the value of authorised claims since the beginning of the week' do
          expect(summary.total_authorised_claim_value).to eq(authorised_claim.amount_assessed + part_authorised_claim.amount_assessed)
        end
      end
    end


    context 'with no VAT applied' do

      let(:submitted_claim)           { create(:submitted_claim, external_user: advocate_without_vat) }
      let(:allocated_claim)           { create(:allocated_claim, external_user: advocate_without_vat) }
      let(:part_authorised_claim)     { create(:part_authorised_claim, external_user: advocate_without_vat)}
      let(:authorised_claim)          { create(:authorised_claim, external_user: advocate_without_vat)}
      let(:summary)                   { Claims::FinancialSummary.new(advocate_without_vat) }
      let!(:old_part_authorised_claim) do
        Timecop.freeze(Time.now - 2.week) do
          claim = create(:part_authorised_claim)
          Timecop.freeze(Time.now + 1.week) do
            claim.determinations.first.update(fees: claim.fees_total/2, expenses: claim.expenses_total)
            claim
          end
        end
      end

      describe '#total_outstanding_claim_value' do
        it 'calculates the value of outstanding claims' do
          expect(summary.total_outstanding_claim_value).to eq(submitted_claim.total + allocated_claim.total)
        end
      end

      describe '#total_authorised_claim_value' do

        it 'calculates the value of authorised claims since the beginning of the week' do
          expect(summary.total_authorised_claim_value).to eq(authorised_claim.amount_assessed + part_authorised_claim.amount_assessed)
        end
      end
    end
  end



  context 'by Providers' do
    let!(:submitted_claim)  { create(:submitted_claim, total: 103.56) }
    let!(:allocated_claim)  { create(:allocated_claim, total: 56.21) }

    let!(:part_authorised_claim) do
      claim = create(:part_authorised_claim, total: 211)
      create(:assessment, claim: claim, fees: 9.99, expenses: 1.55)
      claim
    end
    let!(:authorised_claim) do
      claim = create(:authorised_claim, total: 89)
      create(:assessment, claim: claim, fees: 40, expenses: 49)
      claim
    end

    let(:provider)                { create(:provider) }
    let(:other_provider)          { create(:provider) }
    let(:advocate_admin)          { create(:external_user, :admin, provider: provider, vat_registered: true) }
    let(:advocate_with_vat)       { create(:external_user, provider: provider, vat_registered: true) }
    let(:advocate_without_vat)    { create(:external_user, provider: provider, vat_registered: false) }
    let(:another_advocate_admin)  { create(:external_user, :admin, provider: other_provider) }
    let(:other_provider_claim)    { create(:claim) }


    before do
      other_provider_claim.external_user = another_advocate_admin
      other_provider_claim.creator = another_advocate_admin
    end

    context 'with VAT' do
      let(:submitted_claim)           { create(:submitted_claim, external_user: advocate_with_vat) }
      let(:allocated_claim)           { create(:allocated_claim, external_user: advocate_with_vat) }
      let(:part_authorised_claim)     { create(:part_authorised_claim, external_user: advocate_with_vat)}
      let(:authorised_claim)          { create(:authorised_claim, external_user: advocate_with_vat)}
      let(:summary)                   { Claims::FinancialSummary.new(advocate_with_vat) }
      let!(:old_part_authorised_claim) do
        Timecop.freeze(Time.now - 2.week) do
          claim = create(:part_authorised_claim)
          Timecop.freeze(Time.now + 1.week) do
            claim.determinations.first.update(fees: claim.fees_total/2, expenses: claim.expenses_total)
            claim
          end
        end
      end

      describe '#total_outstanding_claim_value' do
        it 'calculates the value of outstanding claims' do
          expect(summary.total_outstanding_claim_value).to eq(submitted_claim.total + submitted_claim.vat_amount + allocated_claim.total + allocated_claim.vat_amount)
        end
      end

      describe '#total_authorised_claim_value' do
        it 'calculates the value of authorised claims' do
          expect(summary.total_authorised_claim_value).to eq(authorised_claim.amount_assessed + part_authorised_claim.amount_assessed)
        end
      end
    end

    context 'claim without VAT applied' do

      let(:submitted_claim)           { create(:submitted_claim, external_user: advocate_without_vat) }
      let(:allocated_claim)           { create(:allocated_claim, external_user: advocate_without_vat) }
      let(:part_authorised_claim)     { create(:part_authorised_claim, external_user: advocate_without_vat)}
      let(:authorised_claim)          { create(:authorised_claim, external_user: advocate_without_vat)}
      let(:summary)                   { Claims::FinancialSummary.new(advocate_without_vat) }
      let!(:old_part_authorised_claim) do
        Timecop.freeze(Time.now - 2.week) do
          claim = create(:part_authorised_claim)
          Timecop.freeze(Time.now + 1.week) do
            claim.determinations.first.update(fees: claim.fees_total/2, expenses: claim.expenses_total)
            claim
          end
        end
      end

      it 'calculates the value of outstanding claims' do
        expect(summary.total_outstanding_claim_value).to eq(submitted_claim.total + allocated_claim.total)
      end

      it 'calculates the value of authorised claims' do
        expect(summary.total_authorised_claim_value).to eq(authorised_claim.amount_assessed + part_authorised_claim.amount_assessed)
      end

      describe '#outstanding_claims' do
        it 'returns outstanding claims only' do
          expect(summary.outstanding_claims).to include(submitted_claim, allocated_claim)
          expect(summary.outstanding_claims).to_not include(authorised_claim, part_authorised_claim, other_provider_claim)
        end
      end

      describe '#authorised_claims' do
        it 'returns authorised claims only' do
          expect(summary.authorised_claims).to include(authorised_claim, authorised_claim)
          expect(summary.authorised_claims).to_not include(submitted_claim, allocated_claim, other_provider_claim)
        end

        it 'should not include duplicates' do
          create(:redetermination, claim: authorised_claim)
          expect(summary.authorised_claims.count).to eq(2)
        end
      end
    end
  end
end
