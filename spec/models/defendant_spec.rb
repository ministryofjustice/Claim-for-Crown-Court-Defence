# == Schema Information
#
# Table name: defendants
#
#  id                               :integer          not null, primary key
#  first_name                       :string
#  last_name                        :string
#  date_of_birth                    :date
#  order_for_judicial_apportionment :boolean
#  claim_id                         :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#  uuid                             :uuid
#

require 'rails_helper'

RSpec.describe Defendant do
  it { should belong_to(:claim) }

  describe 'validations' do
    context 'draft claim' do
      before { subject.claim = create(:advocate_claim) }

      it { should validate_presence_of(:claim).with_message('blank') }
    end

    context 'non-draft claim' do
      before { subject.claim = create(:submitted_claim) }

      it { should validate_presence_of(:claim).with_message('blank') }
      it { should validate_presence_of(:first_name).with_message('Enter a first name') }
      it { should validate_presence_of(:last_name).with_message('Enter a last name') }
    end

    context 'draft claim from api' do
      before {
        subject.claim = create(:draft_claim)
        subject.claim.source = 'api'
      }

      it { should validate_presence_of(:claim).with_message('blank') }
      it { should validate_presence_of(:first_name).with_message('Enter a first name') }
      it { should validate_presence_of(:last_name).with_message('Enter a last name') }
    end
  end

  describe '#validate_date?' do
    let(:defendant) { Defendant.new(claim: Claim::AdvocateClaim.new(case_type: CaseType.new)) }

    before do
      expect(defendant).to receive(:perform_validation?).and_return(true)
    end

    it 'returns false if there is no associated claim' do
      defendant.claim = nil
      expect(defendant.validate_date?).to be_falsey
    end

    it 'returns false if there is a claim but no case type' do
      defendant.claim.case_type = nil
      expect(defendant.validate_date?).to be_falsey
    end

    it 'returns true if there is a claim with any case type' do
      expect(defendant.validate_date?).to be true
    end
  end

  context 'representation orders' do
    let(:defendant) { create(:defendant, claim: create(:advocate_claim)) }

    it 'is valid if there is one representation order that isnt blank' do
      expect(defendant).to be_valid
    end

    context 'draft claim' do
      it 'is valid if there is more than one representation order' do
        defendant.representation_orders << create(:representation_order)
        expect(defendant).to be_valid
      end
    end

    context 'submitted claim' do
      before do
        defendant.claim = create(:submitted_claim)
        defendant.save
      end

      it 'is not valid if there are no representation orders' do
        defendant.representation_orders = []
        expect(defendant).not_to be_valid
        expect(defendant.errors).not_to be_blank
      end
    end
  end

  context 'name presentation methods' do
    let(:claim) { create(:advocate_claim) }

    # Do we still need this now we aren't using it on the summary page?
    describe '#name' do
      it 'joins first name and last name together' do
        defendant = create(:defendant, first_name: 'Roberto', last_name: 'Smith', claim_id: claim.id)
        expect(defendant.name).to eq('Roberto Smith')
      end

      it 'returns empty string if defendant is uninitialized' do
        defendant = Defendant.new(claim_id: claim.id)
        expect(defendant.name).to eq ' '
      end
    end

    describe '#name and initial' do
      it 'returns initial and surname' do
        defendant = create(:defendant, first_name: 'Roberto', last_name: 'Smith', claim_id: claim.id)
        expect(defendant.name_and_initial).to eq('R. Smith')
      end

      it 'returns empty string if defendant is uninitialised' do
        defendant = Defendant.new(claim_id: claim.id)
        expect(defendant.name_and_initial).to eq ''
      end
    end
  end

  describe '#earliest_representation_order' do
    subject(:defendant) { described_class.new }

    context 'when there are no representation orders' do
      subject(:defendant) { build(:defendant, representation_orders: []) }

      specify { expect(defendant.earliest_representation_order).to be_nil }
    end

    context 'when there are representation orders' do
      let(:base_date) { 3.months.ago.to_date }
      let(:expected_representation_order) {
        build(:representation_order, representation_order_date: base_date - 2.days)
      }
      let(:later_representation_order) {
        build(:representation_order, representation_order_date: base_date + 3.days)
      }
      let(:representation_orders) {
        [
          build(:representation_order, representation_order_date: nil),
          later_representation_order,
          build(:representation_order, representation_order_date: nil),
          expected_representation_order,
          build(:representation_order, representation_order_date: nil)
        ]
      }

      subject(:defendant) { build(:defendant, representation_orders:) }

      it 'returns the earliest representation order' do
        expect(defendant.earliest_representation_order).to eq(expected_representation_order)
      end
    end
  end
end
