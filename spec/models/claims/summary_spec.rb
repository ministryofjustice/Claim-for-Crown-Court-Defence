require 'rails_helper'

RSpec.describe Claims::Summary, type: :model do
  let!(:submitted_claim) { create(:claim, state: 'submitted', total: 103.56) }
  let!(:allocated_claim) { create(:claim, state: 'allocated', total: 56.21) }
  let!(:paid_claim) { create(:claim, state: 'paid', total: 89) }
  let(:advocate) { create(:advocate) }

  context 'by advocate' do

    subject { Claims::Summary.new(advocate) }

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

  end

  context 'by Chambers' do
    let!(:chamber) { create(:chamber) }
    let(:another_advocate) { create(:advocate, chamber: chamber) }

    let!(:another_submitted_claim) { create(:claim, state: 'submitted', total: 33.56) }
    let!(:another_allocated_claim) { create(:claim, state: 'allocated', total: 66.21) }
    let!(:another_paid_claim) { create(:claim, state: 'paid', total: 29.6) }

    before do
      advocate.chamber = chamber
      advocate.save

      advocate.claims << [submitted_claim, allocated_claim, paid_claim]
      another_advocate.claims << [another_submitted_claim, another_allocated_claim, another_paid_claim]
    end

    subject { Claims::Summary.new(chamber) }

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

  end

end
