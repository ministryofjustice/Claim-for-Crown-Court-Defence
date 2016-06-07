# == Schema Information
#
# Table name: determinations
#
#  id            :integer          not null, primary key
#  claim_id      :integer
#  type          :string
#  fees          :decimal(, )      default(0.0)
#  expenses      :decimal(, )      default(0.0)
#  total         :decimal(, )
#  created_at    :datetime
#  updated_at    :datetime
#  vat_amount    :float            default(0.0)
#  disbursements :decimal(, )      default(0.0)
#

require 'rails_helper'


describe Redetermination do
  let(:claim) { FactoryGirl.create :claim }


  context 'automatic calculation of total' do
    it 'should calculate the total on save' do
      rd = FactoryGirl.create :redetermination
      expect(rd.total).to eq(rd.fees + rd.expenses + rd.disbursements)
    end
  end

  context 'default scope' do
    it 'should return the redeterminations in order of creation date' do
      date_1 = 2.months.ago
      date_2 = 1.month.ago
      date_3 = 1.week.ago

      # Given a number of redeterminations written at various times
      [date_3, date_1, date_2].each do |date|
        Timecop.freeze(date) do
          FactoryGirl.create :redetermination, claim: claim
        end
      end
      # when I call claim.redeterminations
      rds = claim.redeterminations

      # it should return them in created_at order - con vert to integer to remove precesion pproblems on travis
      expect(rds.map(&:created_at).map(&:to_i)).to eq([date_1.to_i, date_2.to_i, date_3.to_i])
    end
  end
end
