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
require_relative 'shared_examples_for_defendant_uplifts'
require_relative 'shared_examples_for_duplicable'

RSpec.describe Fee::BasicFee do
  it { should belong_to(:fee_type) }
  it { should validate_presence_of(:claim).with_message('blank') }
  it { should validate_presence_of(:fee_type).with_message('blank') }

  include_examples 'defendant uplift delegation'
  include_examples 'duplicable fee'

  describe 'default scope' do
    it 'should order by claim id and fee type id ascending' do
      expect(Fee::BasicFee.all.to_sql).to include('ORDER BY "fees"."id" ASC, "fees"."claim_id" ASC, "fees"."fee_type_id" ASC')
    end
  end

  describe '#calculated?' do
    it 'should return false for fees flagged as uncalculated' do
      ppe = FactoryBot.create(:basic_fee_type, code: 'PPE', calculated: false)
      fee = FactoryBot.create(:basic_fee, fee_type: ppe)
      expect(fee.calculated?).to be false
    end
    it 'should return true for any other fees' do
      saf = FactoryBot.create(:basic_fee_type, code: 'SAF')
      fee = FactoryBot.create(:basic_fee, fee_type: saf)
      expect(fee.calculated?).to be true
    end
  end
end
