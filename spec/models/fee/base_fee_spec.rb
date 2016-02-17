# == Schema Information
#
# Table name: fees
#
#  id          :integer          not null, primary key
#  claim_id    :integer
#  fee_type_id :integer
#  quantity    :integer
#  amount      :decimal(, )
#  created_at  :datetime
#  updated_at  :datetime
#  uuid        :uuid
#  rate        :decimal(, )
#

require 'rails_helper'

module Fee
  RSpec.describe Fee::BaseFee, type: :model do
    it { should belong_to(:claim) }
    it { should have_many(:dates_attended) }

    describe 'blank quantity should be set to zero before validation' do
      it 'should replace blank quantities with zero before save' do
        fee = FactoryGirl.build :misc_fee, quantity: nil
        expect(fee).to be_valid
        expect(fee.quantity).to eq 0
      end
    end

    describe 'blank rate should be set to zero before validation' do
      it 'should replace blank rate with zero before save' do
        fee = FactoryGirl.build :misc_fee, rate: nil
        expect(fee).to be_valid
        expect(fee.rate).to eq 0
      end
    end

    describe 'blank amount with blank quantity and rate should be set to zero before validation' do
      it 'should replace blank amount with zero before save' do
        fee = FactoryGirl.build :misc_fee, quantity: nil, rate: nil, amount: nil
        expect(fee).to be_valid
        expect(fee.amount).to eq 0
      end
    end

    describe 'non-existent fee_type_id' do
      it 'does not validate' do
        fee = FactoryGirl.build :misc_fee, quantity: 1, rate: 5, amount: 5, fee_type_id: 0
        expect(fee).not_to be_valid
        expect(fee.errors.full_messages).to eq(["Fee type blank"])
      end
    end

    describe '#calculate_amount' do

      # this should be removed after gamma/private beta claims archived/deleted
      context 'for fees entered before rate was reintroduced' do
        it 'amount is NOT recalculated and rate presence is NOT validated' do
          fee = FactoryGirl.build :misc_fee, quantity: 10, rate: nil, amount: 255
          fee.claim.force_validation = true
          expect(fee).to be_valid
          expect(fee.amount).to eq 255.00
        end
      end

      # this will become default after gamma/private beta claims archived/deleted
      context 'for fees entered after rate was reintroduced' do
        it 'amount is calculated as quantity * rate before validation' do
          fee = FactoryGirl.build :misc_fee, quantity: 12, rate: 3.01
          fee.claim.force_validation = true
          expect(fee).to be_valid
          expect(fee.amount).to eq 36.12
        end
      end

      context 'for fees not requiring calculation' do
        let(:fee) { fee = FactoryGirl.build :basic_fee, :ppe_fee, quantity: 999, rate: 2.0, amount: 999 }
        it 'should not calculate the amount' do
          expect(fee).to be_valid
          expect(fee.amount).to eq 999
        end
      end
    end

    describe '#blank?' do
      it 'should return true if all value fields are zero' do
        fee = FactoryGirl.create :misc_fee, :all_zero
        expect(fee.blank?).to be true
      end
      it 'should return false if any value fields are non zero' do
        fee = FactoryGirl.create :misc_fee
        expect(fee.blank?).to be false
      end
    end

    describe '#present?' do
      it 'should return false if all value fields are zero' do
        fee = FactoryGirl.create :misc_fee, :all_zero
        expect(fee.present?).to be false
      end
      it 'should return true if any value fields are non zero' do
        fee = FactoryGirl.create :misc_fee
        expect(fee.present?).to be true
      end
    end

    describe '#clear' do
      let(:fee) {FactoryGirl.build :misc_fee, :with_date_attended, quantity: 1, amount: 9.99}

      it 'should set fee amount and quantity to nil' do
        fee.clear
        expect(fee.quantity).to eql nil
        expect(fee.amount).to eql nil
      end

      it 'should destroy any child relations (dates attended)' do
        expect(fee.dates_attended.size).to eql 1
        fee.clear
        expect(fee.dates_attended.size).to eql 0
      end
    end

    describe 'comma formatted inputs' do
      [:quantity, :amount].each do |attribute|
        it "converts input for #{attribute} by stripping commas out" do
          fee = build(:misc_fee)
          fee.send("#{attribute}=", '12,321,111')
          expect(fee.send(attribute)).to eq(12321111)
        end
      end
    end
  end
end