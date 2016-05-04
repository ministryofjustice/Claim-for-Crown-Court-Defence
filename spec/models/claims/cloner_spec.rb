require 'rails_helper'
require 'support/database_housekeeping'

RSpec.describe Claims::Cloner, type: :model do

  describe '#clone_rejected_to_new_draft' do
    context 'non-rejected_claims' do
      it 'tests the functionality in the new way' do
        non_rejected_claim = build :claim
        allow(non_rejected_claim).to receive(:rejected?).and_return(false)
        expect{
          non_rejected_claim.clone_rejected_to_new_draft
        }.to raise_error
      end
    end

    context 'rejected_claims' do
      before(:all) do
        @rejected_claim = create_rejected_claim
        @cloned_claim = @rejected_claim.clone_rejected_to_new_draft
      end

      after(:all) do
        clean_database
      end

      it 'creates a draft claim' do
        expect(@cloned_claim).to be_draft
      end

      it 'does not clone last_submitted_at' do
        expect(@cloned_claim.last_submitted_at).to be_nil
      end

      it 'does not clone original_submission_date' do
        expect(@cloned_claim.original_submission_date).to be_nil
      end

      it 'does not clone the uuid' do
        expect(@cloned_claim.reload.uuid).to_not eq(@rejected_claim.uuid)
      end

      it 'does not clone the uuids of fees' do
        expect(@cloned_claim.fees.map(&:reload).map(&:uuid)).to_not match_array(@rejected_claim.fees.map(&:reload).map(&:uuid))
      end

      it 'does not clone the uuids of expenses' do
        expect(@cloned_claim.expenses.map(&:reload).map(&:uuid)).to_not match_array(@rejected_claim.expenses.map(&:reload).map(&:uuid))
      end

      it 'does not clone the uuids of documents' do
        expect(@cloned_claim.documents.map(&:reload).map(&:uuid)).to_not match_array(@rejected_claim.documents.map(&:reload).map(&:uuid))
      end

      it 'does not clone the uuids of defendants' do
        expect(@cloned_claim.defendants.map(&:reload).map(&:uuid)).to_not match_array(@rejected_claim.defendants.map(&:reload).map(&:uuid))
      end

      it 'does not clone the uuids of representation orders' do
        cloned_claim_uuids = @cloned_claim.defendants.map(&:reload).map { |d| d.representation_orders.map(&:reload).map(&:uuid ) }.flatten
        rejected_claim_uuids = @rejected_claim.defendants.map(&:reload).map { |d| d.representation_orders.map(&:reload).map(&:uuid ) }.flatten
        expect(cloned_claim_uuids).to_not match_array(rejected_claim_uuids)
      end

      it 'does not clone the uuids of expense dates attended' do
        cloned_claim_uuids = @cloned_claim.expenses.map(&:reload).map { |e| e.dates_attended.map(&:reload).map(&:uuid ) }.flatten
        rejected_claim_uuids = @rejected_claim.expenses.map(&:reload).map { |e| e.dates_attended.map(&:reload).map(&:uuid ) }.flatten
        expect(cloned_claim_uuids).to_not match_array(rejected_claim_uuids)
      end

      it 'does not clone the uuids of fee dates attended' do
        cloned_claim_uuids = @cloned_claim.fees.map(&:reload).map { |e| e.dates_attended.map(&:reload).map(&:uuid ) }.flatten
        rejected_claim_uuids = @rejected_claim.fees.map(&:reload).map { |e| e.dates_attended.map(&:reload).map(&:uuid ) }.flatten
        expect(cloned_claim_uuids).to_not match_array(rejected_claim_uuids)
      end

      it 'clones the fees' do
        expect(@cloned_claim.fees.count).to eq(@rejected_claim.fees.count)

        @cloned_claim.fees.each_with_index do |fee, index|
          expect(fee.amount).to eq(@rejected_claim.fees[index].amount)
        end
      end

      it 'clones the fee\'s dates attended' do
        expect(@cloned_claim.fees.map { |e| e.dates_attended.count }).to eq(@rejected_claim.fees.map { |e| e.dates_attended.count })
      end

      it 'clones the expenses' do
        expect(@cloned_claim.expenses.size).to eq(@rejected_claim.expenses.size)
      end

      it 'clones the expense\'s dates attended' do
        expect(@cloned_claim.expenses.map { |e| e.dates_attended.count }).to eq(@rejected_claim.expenses.map { |e| e.dates_attended.count })
      end

      it 'clones the disbursements' do
        expect(@cloned_claim.disbursements.size).to eq(@rejected_claim.disbursements.size)
        expect(@cloned_claim.disbursements.map(&:net_amount)).to eq(@rejected_claim.disbursements.map(&:net_amount))
        expect(@cloned_claim.disbursements.map(&:vat_amount)).to eq(@rejected_claim.disbursements.map(&:vat_amount))
      end

      it 'clones the defendants' do
        expect(@cloned_claim.defendants.count).to eq(@rejected_claim.defendants.count)
        expect(@cloned_claim.defendants.map(&:name)).to eq(@rejected_claim.defendants.map(&:name))
      end

      it 'clones the defendant\'s representation orders' do
        expect(@cloned_claim.defendants.map { |d| d.representation_orders.count }).to eq(@rejected_claim.defendants.map { |d| d.representation_orders.count })
      end

      it 'clones the documents' do
        expect(@cloned_claim.documents.count).to eq(1)
        expect(@cloned_claim.documents.count).to eq(@rejected_claim.documents.count)

      end

      it 'generates a new form_id for the cloned claim' do
        expect(@cloned_claim.form_id).to_not be_blank
        expect(@cloned_claim.form_id).to_not eq(@rejected_claim.form_id)
      end

      it 'copies the new form_id to the cloned documents' do
        expect(@cloned_claim.documents.map(&:reload).map(&:form_id).uniq).to eq([@cloned_claim.form_id])
      end

      it 'does not clone determinations - assessments or redeterminations' do
        expect(@rejected_claim.redeterminations.count).to eq(1)
        expect(@cloned_claim.redeterminations.count).to eq(0)

        expect(@rejected_claim.assessment.nil?).to eq(false)
        expect(@cloned_claim.assessment.nil?).to eq(true)
      end

      it 'does not clone certifications' do
        expect(@rejected_claim.certification).to_not be_nil
        expect(@cloned_claim.certification).to be_nil
      end
    end

    def create_rejected_claim
      rejected_claim = create(:rejected_claim)
      create(:certification, claim: rejected_claim)
      rejected_claim.fees.each do |fee|
        fee.dates_attended << create(:date_attended)
      end
      rejected_claim.expenses << create(:expense)
      rejected_claim.expenses.each do |expense|
        expense.dates_attended << create(:date_attended)
      end
      rejected_claim.disbursements << create(:disbursement)
      create(:redetermination, claim: rejected_claim)
      rejected_claim.documents << create(:document)
      rejected_claim
    end
  end
end