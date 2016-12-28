# == Schema Information
#
# Table name: fees
#
#  id                    :integer          not null, primary key
#  claim_id              :integer
#  fee_type_id           :integer
#  quantity              :decimal(, )
#  amount                :decimal(, )
#  created_at            :datetime
#  updated_at            :datetime
#  uuid                  :uuid
#  rate                  :decimal(, )
#  type                  :string
#  warrant_issued_date   :date
#  warrant_executed_date :date
#  sub_type_id           :integer
#  case_numbers          :string
#  date                  :date
#

require 'rails_helper'


module Fee

  class FeeDouble < Fee::BaseFee
  end

  RSpec.describe Fee::FeeDouble, type: :model do

    let(:subject)   { FeeDouble.new }

    it { should belong_to(:claim) }
    it { should have_many(:dates_attended) }

    before(:each) { allow(subject).to receive(:quantity_is_decimal?).and_return(false) }

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
      context 'agfs claims' do
        let(:claim) { build :advocate_claim }
        let(:misc_fee_type) { build :misc_fee_type }
        let(:fee) { build :misc_fee, fee_type: misc_fee_type, quantity: 10, rate: 11, amount: 255, claim: claim }

        it 'should recalculate amount if fee type is calculated' do
            fee.claim.force_validation = true
            expect(fee).to be_valid
            expect(fee.amount).to eq 110
        end
        it 'should NOT recalculate amount if fee type is NOT calculated' do
          misc_fee_type.calculated = false
          fee.rate = nil
          fee.claim.force_validation = true
          expect(fee).to be_valid
          expect(fee.amount).to eq 255
        end
        it 'should ONLY recalculate amount if claim is editable' do
          claim.submit!
          claim.force_validation = true
          fee.rate = nil
          expect(fee).to be_valid
          expect(fee.amount).to eq 255
        end
      end

      context 'lgfs claims' do
        let(:claim) { build :litigator_claim }
        let(:misc_fee_type) { build :misc_fee_type, :lgfs }
        let(:fee) { build :misc_fee, fee_type: misc_fee_type, quantity: 10, rate: 11, amount: 255, claim: claim }

        it 'should NOT recalculate amount' do
          fee.rate = 0
          fee.claim.force_validation = true
          expect(fee).to be_valid
          expect(fee.amount).to eq 255
        end
      end
    end

  end

  context 'type logic' do
    before(:all) do
      @basic_fee = BasicFee.new
      @misc_fee = MiscFee.new
      @fixed_fee = FixedFee.new
      @grad_fee = GraduatedFee.new
      @warrant_fee = WarrantFee.new
      @interim_fee = InterimFee.new
      @transfer_fee = TransferFee.new
    end

    describe '#is_basic?' do
      it 'returns true or false as expected' do
        expect(@basic_fee.is_basic?).to be true
        expect(@misc_fee.is_basic?).to be false
        expect(@fixed_fee.is_basic?).to be false
        expect(@grad_fee.is_basic?).to be false
        expect(@warrant_fee.is_basic?).to be false
        expect(@interim_fee.is_basic?).to be false
        expect(@transfer_fee.is_basic?).to be false
      end
    end

    describe '#is_misc?' do
      it 'returns true or false as expected' do
        expect(@basic_fee.is_misc?).to be false
        expect(@misc_fee.is_misc?).to be true
        expect(@fixed_fee.is_misc?).to be false
        expect(@grad_fee.is_misc?).to be false
        expect(@warrant_fee.is_misc?).to be false
        expect(@interim_fee.is_misc?).to be false
        expect(@transfer_fee.is_misc?).to be false
      end
    end

    describe '#is_fixed?' do
      it 'returns true or false as expected' do
        expect(@basic_fee.is_fixed?).to be false
        expect(@misc_fee.is_fixed?).to be false
        expect(@fixed_fee.is_fixed?).to be true
        expect(@grad_fee.is_fixed?).to be false
        expect(@warrant_fee.is_fixed?).to be false
        expect(@interim_fee.is_fixed?).to be false
        expect(@transfer_fee.is_fixed?).to be false
      end
    end

    describe '#is_graduated?' do
      it 'returns true or false as expected' do
        expect(@basic_fee.is_graduated?).to be false
        expect(@misc_fee.is_graduated?).to be false
        expect(@fixed_fee.is_graduated?).to be false
        expect(@grad_fee.is_graduated?).to be true
        expect(@warrant_fee.is_graduated?).to be false
        expect(@interim_fee.is_graduated?).to be false
        expect(@transfer_fee.is_graduated?).to be false
      end
    end

    describe '#is_warrant?' do
      it 'returns true or false as expected' do
        expect(@basic_fee.is_warrant?).to be false
        expect(@misc_fee.is_warrant?).to be false
        expect(@fixed_fee.is_warrant?).to be false
        expect(@grad_fee.is_warrant?).to be false
        expect(@warrant_fee.is_warrant?).to be true
        expect(@interim_fee.is_warrant?).to be false
        expect(@transfer_fee.is_warrant?).to be false
      end
    end

    describe '#is_interim?' do
      it 'returns true or false as expected' do
        expect(@basic_fee.is_interim?).to be false
        expect(@misc_fee.is_interim?).to be false
        expect(@fixed_fee.is_interim?).to be false
        expect(@grad_fee.is_interim?).to be false
        expect(@warrant_fee.is_interim?).to be false
        expect(@interim_fee.is_interim?).to be true
        expect(@transfer_fee.is_interim?).to be false
      end
    end

    describe '#is_transfer?' do
      it 'returns true or false as expected' do
        expect(@basic_fee.is_transfer?).to be false
        expect(@misc_fee.is_transfer?).to be false
        expect(@fixed_fee.is_transfer?).to be false
        expect(@grad_fee.is_transfer?).to be false
        expect(@warrant_fee.is_transfer?).to be false
        expect(@interim_fee.is_transfer?).to be false
        expect(@transfer_fee.is_transfer?).to be true
      end
    end
  end
end
