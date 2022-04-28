require 'rails_helper'

RSpec.describe DefendantValidator, type: :validator do
  let(:claim)     { build(:claim) }
  let(:defendant) { build(:defendant, claim: claim) }

  before do
    claim.force_validation = true
  end

  describe '#validate_claim' do
    it { should_error_if_not_present(defendant, :claim, 'blank') }
  end

  describe '#first_name' do
    it { should_error_if_not_present(defendant, :first_name, 'Enter a first name') }
    it { should_error_if_exceeds_length(defendant, :first_name, 40, 'First name is too long') }
  end

  describe '#last_name' do
    it { should_error_if_not_present(defendant, :last_name, 'Enter a last name') }
    it { should_error_if_exceeds_length(defendant, :last_name, 40, 'Last name is too long') }
  end

  describe '#validate_date_of_birth' do
    it { should_error_if_not_present(defendant, :date_of_birth, 'Enter a date of birth') }
    it { should_error_if_before_specified_date(defendant, :date_of_birth, 120.years.ago, 'Check the date of birth') }
    it { should_error_if_after_specified_date(defendant, :date_of_birth, 10.years.ago, 'Check the date of birth') }
  end

  describe '#validate_representation_orders' do
    before do
      defendant.representation_orders.destroy_all
    end

    context 'from api' do
      let(:claim) { build(:claim, source: 'api') }

      it 'does not validate for presence of a rep order' do
        expect(defendant).to be_valid
      end
    end

    context 'not from api' do
      let(:claim) { create(:submitted_claim, source: 'web') }

      it 'validates for presence of a rep order' do
        expect(defendant).to_not be_valid
        expect(
          defendant.errors[:representation_orders_attributes_0_representation_order_date]
        ).to eq ['Enter a representation order date']
        expect(defendant.errors[:representation_orders_attributes_0_maat_reference]).to eq ['Enter a valid MAAT reference']
      end
    end
  end
end
