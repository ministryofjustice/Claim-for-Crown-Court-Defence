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

  class FeeTypeDouble < Fee::BaseFeeType
  end

  RSpec.describe Fee::FeeDouble do
    subject { FeeDouble.new }

    before { allow(subject).to receive(:quantity_is_decimal?).and_return(false) }

    it { should belong_to(:claim) }
    it { should have_many(:dates_attended) }

    context 'duplicable' do
      describe '.duplicate_this' do
        it 'responds to .duplicate_this' do
          expect(described_class).to respond_to(:duplicate_this)
        end

        it { is_expected.to respond_to(:duplicate) }
      end
    end

    context 'zeroise nulls on save' do
      it 'zeroises the amount if null' do
        fee = create(:fixed_fee, :lgfs, amount: nil, rate: nil, quantity: nil)
        fee.save!
        expect(fee.amount).to eq 0.0
      end

      it 'does not zeroise the amount if not null' do
        fee = create(:fixed_fee, amount: nil, rate: 2, quantity: 150)
        fee.save!
        expect(fee.amount).to eq 300.0
      end
    end

    context 'delegations' do
      describe '#description' do
        it { is_expected.to delegate_method(:description).to(:fee_type) }
      end

      describe '#case_uplift?' do
        it { is_expected.to delegate_method(:case_uplift?).to(:fee_type) }
      end

      describe '#orphan_case_uplift?' do
        it { is_expected.to delegate_method(:orphan_case_uplift?).to(:fee_type) }
      end

      describe '#position' do
        it { is_expected.to delegate_method(:position).to(:fee_type) }
      end
    end

    describe 'blank quantity should be set to zero before validation' do
      it 'replaces blank quantities with zero before save' do
        subject.quantity = nil
        subject.valid?
        expect(subject.quantity).to eq 0
      end
    end

    describe 'blank rate should be set to zero before validation' do
      it 'replaces blank rate with zero before save' do
        subject.rate = nil
        subject.valid?
        expect(subject.rate).to eq 0
      end
    end

    describe 'blank amount with blank quantity and rate should be set to zero before validation' do
      it 'replaces blank amount with zero before save' do
        subject.quantity = nil
        subject.rate = nil
        subject.amount = nil
        subject.valid?
        expect(subject.amount).to eq 0
      end
    end

    describe '#blank?' do
      it 'returns true if all value fields are zero' do
        subject.quantity = 0
        subject.rate = 0
        subject.amount = 0
        expect(subject.blank?).to be true
      end

      it 'returns false if any value fields are non zero' do
        subject.rate = 10
        expect(subject.blank?).to be false
      end
    end

    describe '#present?' do
      it 'returns false if all value fields are zero' do
        subject.quantity = 0
        subject.rate = 0
        subject.amount = 0
        expect(subject.present?).to be false
      end

      it 'returns true if any value fields are non zero' do
        subject.rate = 10
        expect(subject.present?).to be true
      end
    end

    describe '#clear' do
      before do
        subject.quantity = 10
        subject.amount = 10
        subject.rate = 2
        subject.case_numbers = 'T20170001,T20170002'
        subject.dates_attended << build(:date_attended)
      end

      it 'sets fee amount, quantity, rate and case_numbers to nil' do
        subject.clear
        expect(subject.quantity).to be_nil
        expect(subject.amount).to be_nil
        expect(subject.rate).to be_nil
        expect(subject.case_numbers).to be_nil
      end

      it 'destroys any child relations (dates attended)' do
        expect(subject.dates_attended.size).to eq 1
        subject.clear
        expect(subject.dates_attended.size).to eq 0
      end
    end

    describe '#numeric_attributes' do
      %i[quantity amount].each do |attribute|
        it "converts input for #{attribute} by stripping commas out" do
          subject.send(:"#{attribute}=", '12,321,111')
          expect(subject.send(attribute)).to eq(12321111)
        end
      end
    end
  end

  RSpec.describe Fee::BaseFee do
    describe '#new' do
      it 'raises BaseFeeAbstractClassError' do
        expect { BaseFee.new }.to raise_error(Fee::BaseFeeAbstractClassError)
      end
    end

    describe '#calculate_amount' do
      context 'agfs claims' do
        let(:claim) { create(:advocate_claim) }
        let(:misc_fee_type) { build(:misc_fee_type) }
        let(:fee) { build(:misc_fee, fee_type: misc_fee_type, quantity: 10, rate: 11, amount: 255, claim:) }

        it 'recalculates amount if fee type is calculated' do
          fee.claim.force_validation = true
          expect(fee).to be_valid
          expect(fee.amount).to eq 110
        end

        it 'does not recalculate amount if fee type is NOT calculated' do
          misc_fee_type.calculated = false
          fee.rate = nil
          fee.claim.force_validation = true
          expect(fee).to be_valid
          expect(fee.amount).to eq 255
        end

        it 'only recalculates amount if claim is editable' do
          claim.submit!
          claim.force_validation = true
          fee.rate = nil
          expect(fee).to be_valid
          expect(fee.amount).to eq 255
        end
      end

      context 'lgfs claims' do
        let(:claim) { build(:litigator_claim) }
        let(:misc_fee_type) { build(:misc_fee_type, :lgfs) }
        let(:fee) { build(:misc_fee, fee_type: misc_fee_type, quantity: 10, rate: 11, amount: 255, claim:) }

        it 'does not recalculate amount' do
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
