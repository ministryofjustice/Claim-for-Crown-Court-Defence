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

class FeeDouble < Fee::BaseFee
end

  RSpec.describe Fee::FeeDouble, type: :model do

    let(:subject)   { FeeDouble.new }

    it { should belong_to(:claim) }
    it { should have_many(:dates_attended) }

    describe 'blank quantity should be set to zero before validation' do
      it 'should replace blank quantities with zero before save' do
        subject.quantity = nil
        subject.valid?
        expect(subject.quantity).to eq 0
      end
    end

    describe 'blank rate should be set to zero before validation' do
      it 'should replace blank rate with zero before save' do
        subject.rate = nil
        subject.valid?
        expect(subject.rate).to eq 0
      end
    end

    describe 'blank amount with blank quantity and rate should be set to zero before validation' do
      it 'should replace blank amount with zero before save' do
        subject.quantity = nil
        subject.rate = nil
        subject.amount = nil
        subject.valid?
        expect(subject.amount).to eq 0
      end
    end

    describe '#blank?' do
      it 'should return true if all value fields are zero' do
        subject.quantity = 0
        subject.rate = 0
        subject.amount = 0
        expect(subject.blank?).to be true
      end
      it 'should return false if any value fields are non zero' do
        subject.rate = 10
        expect(subject.blank?).to be false
      end
    end

    describe '#present?' do
      it 'should return false if all value fields are zero' do
        subject.quantity = 0
        subject.rate = 0
        subject.amount = 0
        expect(subject.present?).to be false
      end
      it 'should return true if any value fields are non zero' do
        subject.rate = 10
        expect(subject.present?).to be true
      end
    end

    describe '#clear' do
      before(:each) do
        subject.quantity = 10
        subject.amount = 10
        subject.dates_attended << FactoryGirl.build(:date_attended)
      end

      it 'should set fee amount and quantity to nil' do
        subject.clear
        expect(subject.quantity).to eql nil
        expect(subject.amount).to eql nil
      end

      it 'should destroy any child relations (dates attended)' do
        expect(subject.dates_attended.size).to eql 1
        subject.clear
        expect(subject.dates_attended.size).to eql 0
      end
    end

    describe 'comma formatted inputs' do
      [:quantity, :amount].each do |attribute|
        it "converts input for #{attribute} by stripping commas out" do
          subject.send("#{attribute}=", '12,321,111')
          expect(subject.send(attribute)).to eq(12321111)
        end
      end
    end

  end

  RSpec.describe Fee::BaseFee, type: :model do

    context '#new' do
      it 'should raise BaseFeeAbstractClassError' do
        expect { BaseFee.new }.to raise_error
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
    end

  end
end