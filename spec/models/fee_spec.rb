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
#

require 'rails_helper'

RSpec.describe Fee, type: :model do
  it { should belong_to(:claim) }
  it { should belong_to(:fee_type) }
  it { should have_many(:dates_attended) }

  it { should validate_presence_of(:fee_type).with_message('Fee type cannot be blank') }
  it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(0) }

  it { should accept_nested_attributes_for(:dates_attended) }

  it 'should be invalid when fee_type is "Basic Fee" and quantity is greater than 1' do
    # basic_fee has id of 1
    fee_type = FactoryGirl.build(:fee_type, description: 'Basic Fee')
    fee = FactoryGirl.build(:fee, fee_type: fee_type, quantity: 2)
    expect(fee.save).to eq false
  end

  describe 'blank quantity should be set to zero' do
    it 'should replace blank quantities with zero before save' do
      fee = FactoryGirl.build :fee, quantity: nil
      expect(fee).to be_valid
      expect(fee.quantity).to eq 0
    end
  end

 describe 'blank amount should be set to zero' do
    it 'should replace blank amounts with zero before save' do
      fee = FactoryGirl.build :fee, amount: nil
      expect(fee).to be_valid
      expect(fee.amount).to eq 0
    end
  end

  describe '.new_blank' do
    it 'should instantiate but not save a fee with all zero values belonging to the claim and fee type' do
      fee_type = FactoryGirl.build :fee_type
      claim = FactoryGirl.build :claim

      fee = Fee.new_blank(claim, fee_type)
      expect(fee.fee_type).to eq fee_type
      expect(fee.claim).to eq claim
      expect(fee.quantity).to eq 0
      expect(fee.amount).to eq 0
      expect(fee).to be_new_record
    end
  end


  describe '#blank?' do
    it 'should return true if all value fields are zero' do
      fee = FactoryGirl.create :fee, :all_zero
      expect(fee.blank?).to be true
    end
    it 'should return false if any value fields are non zero' do
      fee = FactoryGirl.create :fee
      expect(fee.blank?).to be false
    end
  end


  describe '#present?' do
    it 'should return false if all value fields are zero' do
      fee = FactoryGirl.create :fee, :all_zero
      expect(fee.present?).to be false
    end
    it 'should return true if any value fields are non zero' do
      fee = FactoryGirl.create :fee
      expect(fee.present?).to be true
    end
  end

  describe '#category' do
    it 'should return the abbreviateion of the fee type category' do
      cat = FactoryGirl.create :fee_category
      ft  = FactoryGirl.create :fee_type, fee_category: cat
      fee = FactoryGirl.create :fee, fee_type: ft
      expect(fee.category).to eq cat.abbreviation
    end
  end

  describe '.new_from_form_params' do
    it 'should build a new record and attach it to the claim' do
      claim = FactoryGirl.create :claim
      ft = FactoryGirl.create :fee_type
      params = {"fee_type_id"=> ft.id.to_s, "quantity"=>"25", "amount"=>"1125", "_destroy"=>"false"}
      fee = Fee.new_from_form_params(claim, params)
      expect(fee).to be_new_record
      expect(fee.claim).to eq claim
      expect(fee.fee_type).to eq ft
      expect(fee.quantity).to eq 25
      expect(fee.amount.to_f).to eq 1125
    end
  end

  describe '.new_collection_from_form_params' do
    it 'should call Fee.new_from_form_params for every instance in the form params' do
      claim = double claim
      params = { '0' => 'first lot', '1' => 'second lot'}
      expect(Fee).to receive(:new_from_form_params).with(claim, 'first lot')
      expect(Fee).to receive(:new_from_form_params).with(claim, 'second lot')
      Fee.new_collection_from_form_params(claim, params)
    end
  end

  describe '#clear' do
    it 'should set fee amount and quantity to nil' do
      fee = FactoryGirl.build :fee, quantity: 1, amount: 9.99
      fee.clear
      expect(fee.quantity).to eql nil
      expect(fee.amount).to eql nil
    end
  end

  describe 'comma formatted inputs' do
    [:quantity, :amount].each do |attribute|
      it "converts input for #{attribute} by stripping commas out" do
        fee = build(:fee)
        fee.send("#{attribute}=", '12,321,111')
        expect(fee.send(attribute)).to eq(12321111)
      end
    end
  end
end
