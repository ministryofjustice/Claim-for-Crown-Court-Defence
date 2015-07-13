require 'rails_helper'

RSpec.describe Claims::FinancialSummary, type: :model do
  let!(:submitted_claim) { create(:submitted_claim, total: 103.56) }
  let!(:allocated_claim) { create(:allocated_claim, total: 56.21) }
  # let!(:paid_claim) { create(:claim, state: 'paid', total: 89) }
  let!(:paid_claim)   {claim = FactoryGirl.create(:paid_claim, total: 89) }
  let(:advocate) { create(:advocate) }

  context 'by advocate' do

    subject { Claims::FinancialSummary.new(advocate) }

    before do
      advocate.claims << [submitted_claim, allocated_claim, paid_claim]
    end

    describe '#total_outstanding_claim_value' do
      it 'calculates the value of outstanding claims' do
        expect(subject.total_outstanding_claim_value).to eq(159.77)
      end
    end

    describe '#total_authorised_claim_value' do
      it 'calculates the value of authorised claims' do
        expect(subject.total_authorised_claim_value).to eq(89)
      end
    end

    describe '#outstanding_claims' do
      it 'returns outstanding claims only' do
        expect(subject.outstanding_claims.map(&:id)).to include(submitted_claim.id, allocated_claim.id)
        expect(subject.outstanding_claims.map(&:id)).to_not include(paid_claim.id)
      end
    end

    describe '#authorised_claims' do
      it 'returns authorised claims only' do
        expect(subject.authorised_claims.map(&:id)).to include(paid_claim.id)
        expect(subject.authorised_claims.map(&:id)).to_not include(submitted_claim.id, allocated_claim.id)
      end
    end

  end

  context 'by Chambers' do
    let!(:chamber) { create(:chamber) }
    let(:another_advocate) { create(:advocate, chamber: chamber) }

    let!(:another_submitted_claim) { create(:submitted_claim, total: 33.56) }
    let!(:another_allocated_claim) { create(:allocated_claim, total: 66.21) }
    let!(:another_paid_claim)      { FactoryGirl.create :paid_claim, total: 29.6 }

    before do
      advocate.chamber = chamber
      advocate.save

      advocate.claims << [submitted_claim, allocated_claim, paid_claim]
      another_advocate.claims << [another_submitted_claim, another_allocated_claim, another_paid_claim]
    end

    subject { Claims::FinancialSummary.new(chamber) }

    describe '.total_outstanding_claim_value' do
      it 'calculates the value of outstanding claims' do
        expect(subject.total_outstanding_claim_value).to eq(259.54)
      end
    end

    describe '.total_authorised_claim_value' do
      it 'calculates the value of authorised claims' do
        expect(subject.total_authorised_claim_value).to eq(118.6)
      end
    end

    describe '#outstanding_claims' do
      it 'returns outstanding claims only' do
        expect(subject.outstanding_claims.map(&:id)).to include(another_submitted_claim.id, another_allocated_claim.id)
        expect(subject.outstanding_claims.map(&:id)).to_not include(another_paid_claim.id)
      end
    end

    describe '#authorised_claims' do
      it 'returns authorised claims only' do
        expect(subject.authorised_claims.map(&:id)).to include(another_paid_claim.id)
        expect(subject.authorised_claims.map(&:id)).to_not include(another_submitted_claim.id, another_allocated_claim.id)
      end
    end

  end

  context 'bug summing decimals' do

    subject { Claims::FinancialSummary.new(advocate) }

    it 'sums up correctly' do

      #  this attempts replicates a summing error I get locally (irb and in browser) when doing claims.sum(:total)
      #  over BigDecimals - however I cannot replicate the failure as a test.

      # i.e from my rails console, the first result is correct the second is not !
      #
      #  > fs.outstanding_claims.inject(0.0) { |total, claim| total += claim.total }.to_s
      # => "9942.55890332963513"
      #  > fs.outstanding_claims.sum(:total).to_s
      # => "248508.33982225015947"

      bd1 = create(:submitted_claim, total: 908.71971356268547)
      bd2 = create(:submitted_claim, total: 1825.02462504223905)
      bd3 = create(:submitted_claim, total: 1818.65467216296309)
      bd4 = create(:submitted_claim, total: 2073.64615377261145)
      bd5 = create(:submitted_claim, total: 418.13695517587028)
      bd6 = create(:submitted_claim, total: 1917.5556319890992)

      advocate.claims << [bd1, bd2, bd3, bd4, bd5, bd6]

      expect(subject.total_outstanding_claim_value).to eq(8961.737751705465)
    end
  end

end
