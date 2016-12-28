# == Schema Information
#
# Table name: fee_types
#
#  id                  :integer          not null, primary key
#  description         :string
#  code                :string
#  created_at          :datetime
#  updated_at          :datetime
#  max_amount          :decimal(, )
#  calculated          :boolean          default(TRUE)
#  type                :string
#  roles               :string
#  parent_id           :integer
#  quantity_is_decimal :boolean          default(FALSE)
#  unique_code         :string
#

require 'rails_helper'

module Fee

  RSpec.describe BaseFeeType, type: :model do

    context '#new' do
      it 'should raise BaseFeeTypeAbstractClassError' do
        expect { BaseFeeType.new }.to raise_error
      end
    end

    context 'behaves like roles' do
      # using MiscFeeType becasue the shared exmaples use a factory, which rules out the use of a class double
      it_behaves_like 'roles', MiscFeeType, MiscFeeType::ROLES
    end
    
  end

  class FeeTypeDouble < BaseFeeType
  end

  RSpec.describe FeeTypeDouble, type: :model do
    
    it { should have_many(:fees) }

    it { should validate_presence_of(:description).with_message('Fee type description cannot be blank') }
    it { should validate_presence_of(:code).with_message('Fee type code cannot be blank') }
    it { should validate_uniqueness_of(:description).with_message('Fee type description must be unique') }

    it { should respond_to(:code) }
    it { should respond_to(:description) }

    describe '.new' do
      it 'raises an error' do
        expect {
          BaseFeeType.new
        }.to raise_error BaseFeeTypeAbstractClassError, 'Fee::BaseFeeType is an abstract class and cannot be instantiated'
      end
    end

    describe '#requires_dates_attended?' do
      it 'returns false' do
        expect(build(:fixed_fee_type).requires_dates_attended?).to be false
        expect(build(:misc_fee_type).requires_dates_attended?).to be false
      end
    end

    describe '#quanity_is_decimal?' do
      it 'should return false' do
        ft = build :basic_fee_type
        expect(ft.quantity_is_decimal).to be false
      end
      it 'should return true' do
        ft = build :misc_fee_type, :spf
        expect(ft.quantity_is_decimal).to be true
      end
    end

    describe  '#fee_category_name' do
      it 'returns the humanised name' do
        expect(build(:transfer_fee_type).fee_category_name).to eq 'Transfer Fee'
        expect(build(:basic_fee_type).fee_category_name).to eq 'Basic Fees'
        expect(build(:fixed_fee_type).fee_category_name).to eq 'Fixed Fees'
        expect(build(:graduated_fee_type).fee_category_name).to eq 'Graduated Fees'
        expect(build(:interim_fee_type).fee_category_name).to eq 'Interim Fees'
        expect(build(:warrant_fee_type).fee_category_name).to eq 'Warrant Fee'
      end
    end

  end

  context 'fee category name' do
    describe '#fee_category_name' do
      it 'returns the correct category name' do
        expect(BasicFeeType.new.fee_category_name).to eq 'Basic Fees'
        expect(MiscFeeType.new.fee_category_name).to eq 'Miscellaneous Fees'
        expect(FixedFeeType.new.fee_category_name).to eq 'Fixed Fees'
        expect(InterimFeeType.new.fee_category_name).to eq 'Interim Fees'
        expect(TransferFeeType.new.fee_category_name).to eq 'Transfer Fee'
        expect(GraduatedFeeType.new.fee_category_name).to eq 'Graduated Fees'
        expect(WarrantFeeType.new.fee_category_name).to eq 'Warrant Fee'
      end
    end
  end

end
