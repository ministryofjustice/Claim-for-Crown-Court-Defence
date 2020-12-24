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

RSpec.describe Assessment do
  let(:claim) { FactoryBot.create :claim }

  context 'validations' do
    context 'fees' do
      it 'should not accept negative values' do
        expect {
          # FactoryBot.create :assessment, claim: claim, fees: -33.55
          claim.assessment.update!(fees: -33.35)
        }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Assessed fees must be greater than or equal to zero'
      end

      it 'should not accept nil values ' do
        expect {
          claim.assessment.update!(fees: nil)
          claim.assessment.save!
        }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Assessed fees must be greater than or equal to zero'
      end
    end

    context 'expenses' do
      it 'should not accept negative values' do
        expect {
          claim.assessment.update!(expenses: -33.55)
        }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Assessed expenses must be greater than or equal to zero'
      end

      it 'should not accept nil values ' do
        expect {
          claim.assessment.update!(expenses: nil)
        }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Assessed expenses must be greater than or equal to zero'
      end
    end

    context 'disbursements' do
      it 'should not accept negative values' do
        expect {
          claim.assessment.update!(disbursements: -33.55)
        }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Assessed disbursements must be greater than or equal to zero'
      end

      it 'should not accept nil values ' do
        expect {
          claim.assessment.update!(disbursements: nil)
        }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Assessed disbursements must be greater than or equal to zero'
      end
    end
  end

  context 'automatic calculation of total' do
    it 'should calculate the total on save' do
      ass = create :assessment, expenses: 102.33, fees: 44.86
      ass = claim.assessment
      expect(ass.total).to eq(ass.fees + ass.expenses + ass.disbursements)
    end
  end

  RSpec.shared_examples 'calculates assessment VAT' do
    let(:assessment) { claim.assessment }

    it 'determines rate using VatRate model' do
      expect(VatRate).to receive(:vat_amount).at_least(:once).and_call_original
      assessment.update!(fees: 150.0, expenses: 250.0, disbursements: 0)
    end

    it 'updates determination\'s vat_amount' do
      expect { assessment.update!(fees: 150.0, expenses: 250.0, disbursements: 0) }.to change(assessment, :vat_amount).from(0).to(80)
    end
  end

  context 'automatic calculation of VAT' do
    describe '#calculate_vat' do
      context 'advocate claims' do
        let(:claim) { create(:advocate_claim, apply_vat: true) }
        include_examples 'calculates assessment VAT'
      end

      context 'advocate supplementary claims' do
        let(:claim) { create(:advocate_supplementary_claim, apply_vat: true) }
        include_examples 'calculates assessment VAT'
      end

      context 'advocate interim claims' do
        let(:claim) { create(:advocate_interim_claim, apply_vat: true) }
        include_examples 'calculates assessment VAT'
      end

      context 'litigator claims' do
        let(:assessment) { create(:litigator_claim, apply_vat: true).assessment }
        it 'should not update/calculate the VAT amount' do
          expect { assessment.update!(fees: 100.0, expenses: 250.0, disbursements: 150.0) }.not_to change(assessment, :vat_amount)
        end
      end
    end
  end

  context '#zeroize!' do
    it 'should zeroize values and save' do
      assessment = create(:assessment, :random_amounts)
      expect(assessment.fees).not_to eq 0
      expect(assessment.expenses).not_to eq 0
      expect(assessment.disbursements).not_to eq 0
      expect(assessment.total).not_to eq 0
      assessment.zeroize!

      reloaded_assessment = Assessment.find assessment.id
      expect(reloaded_assessment.fees).to eq 0
      expect(reloaded_assessment.expenses).to eq 0
      expect(reloaded_assessment.disbursements).to eq 0
      expect(reloaded_assessment.total).to eq 0
    end
  end
end
