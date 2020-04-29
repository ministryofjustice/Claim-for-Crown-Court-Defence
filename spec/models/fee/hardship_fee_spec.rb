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

RSpec.describe Fee::HardshipFee do
  it { should belong_to(:fee_type) }
  it { should validate_presence_of(:claim).with_message('blank') }
  it { should validate_presence_of(:fee_type).with_message('blank') }

  describe '.is_hardship?' do
    subject(:hardship_fee) { described_class.new.is_hardship? }

    it { is_expected.to be true }
  end
end
