require 'rails_helper'
require File.dirname(__FILE__) + '/validation_helpers'

describe DefendantValidator do

  include ValidationHelpers

  let(:claim)     { FactoryGirl.build(:claim, force_validation: true) }
  let(:defendant) { FactoryGirl.build :defendant, claim: claim }

  describe '#validate_claim' do
    it { should_error_if_not_present(defendant, :claim, 'blank') }
  end

  describe '#first_name' do
    it { should_error_if_not_present(defendant, :first_name, 'blank') }
  end

  describe '#last_name' do
    it { should_error_if_not_present(defendant, :last_name, 'blank') }
  end

  describe '#validate_date_of_birth' do
    it { should_error_if_not_present(defendant, :date_of_birth, 'blank') }
    it { should_error_if_before_specified_date(defendant, :date_of_birth, 120.years.ago, 'check') }
    it { should_error_if_after_specified_date(defendant, :date_of_birth, 10.years.ago, 'check') }
  end

  describe '#validate_representation_orders' do
    before do
      defendant.representation_orders.destroy_all
    end

    context 'from api' do
      let(:claim) { FactoryGirl.build(:claim, source: 'api') }

      it 'should not validate for presence of a rep order' do
        expect(defendant).to be_valid
      end
    end

    context 'not from api' do
      let(:claim) { FactoryGirl.create(:submitted_claim, source: 'web') }

      it 'should validate for presence of a rep order' do
        expect(defendant).to_not be_valid
        expect(defendant.errors[:representation_order_1_representation_order_date]).to eq ['blank']
        expect(defendant.errors[:representation_order_1_maat_reference]).to eq ['invalid']
      end
    end
  end
end
