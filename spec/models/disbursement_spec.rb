# == Schema Information
#
# Table name: disbursements
#
#  id                   :integer          not null, primary key
#  disbursement_type_id :integer
#  claim_id             :integer
#  net_amount           :decimal(, )
#  vat_amount           :decimal(, )
#  created_at           :datetime
#  updated_at           :datetime
#  total                :decimal(, )      default(0.0)
#

require 'rails_helper'
require 'support/database_housekeeping'

RSpec.describe Disbursement, type: :model do

  it { should belong_to(:disbursement_type) }
  it { should belong_to(:claim) }

  it { should validate_presence_of(:claim).with_message('blank') }

  describe 'comma formatted inputs' do
    [:net_amount, :vat_amount].each do |attribute|
      it "converts input for #{attribute} by stripping commas out" do
        disbursement = build(:disbursement)
        disbursement.send("#{attribute}=", '1,321.55')
        expect(disbursement.send(attribute)).to eq(1321.55)
      end
    end
  end

  describe 'update claim totals' do
    before :all do
      @claim = create(:claim, :without_fees)

      [[5.0, 1.5], [3.0, 1.0]].each do |net, vat|
        create(:disbursement, claim: @claim, net_amount: net, vat_amount: vat)
      end
    end

    after :all do
      clean_database
    end

    it 'calculates the disbursements total amount' do
      expect(@claim.disbursements_total).to eq(8.0)
    end

    it 'calculates the claim total amount' do
      expect(@claim.total).to eq(8.0)
    end

    it 'calculates the claim vat amount (on claim submit)' do
      expect{ @claim.submit! }.to change{ @claim.vat_amount }.by(2.5)
    end
  end
end
