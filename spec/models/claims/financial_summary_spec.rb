require 'rails_helper'

RSpec.describe Claims::FinancialSummary, type: :model do
  # Uses default VAT rate factory (implicitly) with VAT rate of 17.5%

  context 'by advocate' do

    # TODO should not rely on values in factory which may change
    let!(:submitted_claim)  { create(:submitted_claim,) }
    let!(:allocated_claim)  { create(:allocated_claim,) }
    let!(:old_part_authorised_claim) do
      Timecop.freeze(Time.now - 1.week) do
        claim = create(:part_authorised_claim)
        create(:assessment, claim: claim, fees: claim.fees_total/2, expenses: claim.expenses_total)
        claim
      end
    end

    let!(:part_authorised_claim) do
      claim = create(:part_authorised_claim)
      create(:assessment, claim: claim, fees: claim.fees_total/2, expenses: claim.expenses_total)
      claim
    end

    let!(:authorised_claim) do
      claim = create(:authorised_claim)
      create(:assessment, claim: claim, fees: claim.fees_total, expenses: claim.expenses_total)
      claim
    end

    let(:advocate) { create(:advocate) }
    let(:another_advocate) { create(:advocate) }

    let(:other_advocate_claim) { create(:claim) }

    subject { Claims::FinancialSummary.new(advocate) }

    before do
      advocate.claims << [submitted_claim, allocated_claim, part_authorised_claim, authorised_claim, old_part_authorised_claim]
      another_advocate.claims << other_advocate_claim
    end

    describe '#total_outstanding_claim_value' do
      context 'claim with VAT applied' do
        before do
          submitted_claim.apply_vat = true
          submitted_claim.save!
        end

        it 'calculates the value of outstanding claims' do
          expect(subject.total_outstanding_claim_value).to eq(54.38)
        end
      end

      context 'claim without VAT applied' do
        it 'calculates the value of outstanding claims' do
          expect(subject.total_outstanding_claim_value).to eq(50.00)
        end
      end
    end

    describe '#total_authorised_claim_value' do
      context 'when VAT applied to a claim' do
        before do
          part_authorised_claim.apply_vat = true
          part_authorised_claim.save!
        end

        it 'calculates the value of authorised claims since the beginning of the week' do
          expect(subject.total_authorised_claim_value).to eq(39.69)
        end
      end

      context 'when no claim with VAT applied present' do
        it 'calculates the value of authorised claims since the beginning of the week' do
          expect(subject.total_authorised_claim_value).to eq(37.5)
        end
      end
    end

    describe '#outstanding_claims' do
      it 'returns outstanding claims only' do
        expect(subject.outstanding_claims).to include(submitted_claim, allocated_claim)
        expect(subject.outstanding_claims).to_not include(authorised_claim, part_authorised_claim, other_advocate_claim, old_part_authorised_claim)
      end
    end

    describe '#authorised_claims' do
      it 'returns authorised claims only (since the beginning of the week)' do
        expect(subject.authorised_claims).to include(authorised_claim, authorised_claim)
        expect(subject.authorised_claims).to_not include(submitted_claim, allocated_claim, other_advocate_claim, old_part_authorised_claim)
      end
    end
  end

  context 'by Chambers' do
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

    let(:chamber) { create(:chamber) }
    let(:other_chamber) { create(:chamber) }
    let(:advocate_admin) { create(:advocate, role: 'admin', chamber: chamber) }
    let(:advocate) { create(:advocate, chamber: chamber) }
    let(:another_advocate_admin) { create(:advocate, role: 'admin', chamber: other_chamber) }
    let(:other_chamber_claim) { create(:claim) }

    subject { Claims::FinancialSummary.new(advocate) }

    before do
      advocate.claims << [submitted_claim, allocated_claim, part_authorised_claim, authorised_claim]
      another_advocate_admin.claims << other_chamber_claim
    end

    describe '#total_outstanding_claim_value' do
      context 'claim with VAT applied' do
        before do
          submitted_claim.apply_vat = true
          submitted_claim.save!
        end

        it 'calculates the value of outstanding claims' do
          expect(subject.total_outstanding_claim_value).to eq(54.38)
        end
      end

      context 'claim without VAT applied' do
        it 'calculates the value of outstanding claims' do
          expect(subject.total_outstanding_claim_value).to eq(50.0)
        end
      end
    end

    describe '#total_authorised_claim_value' do
      context 'when VAT applied to a claim' do
        before do
          part_authorised_claim.apply_vat = true
          part_authorised_claim.save!
        end

        it 'calculates the value of authorised claims' do
          expect(subject.total_authorised_claim_value).to eq(102.56)
        end
      end

      context 'when no claim with VAT applied present' do
        it 'calculates the value of authorised claims' do
          expect(subject.total_authorised_claim_value).to eq(100.54)
        end
      end
    end

    describe '#outstanding_claims' do
      it 'returns outstanding claims only' do
        expect(subject.outstanding_claims).to include(submitted_claim, allocated_claim)
        expect(subject.outstanding_claims).to_not include(authorised_claim, part_authorised_claim, other_chamber_claim)
      end
    end

    describe '#authorised_claims' do
      it 'returns authorised claims only' do
        expect(subject.authorised_claims).to include(authorised_claim, authorised_claim)
        expect(subject.authorised_claims).to_not include(submitted_claim, allocated_claim, other_chamber_claim)
      end
    end
  end
end
