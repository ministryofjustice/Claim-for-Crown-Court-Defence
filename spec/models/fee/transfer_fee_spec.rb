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
#

require 'rails_helper'

module Fee
  describe TransferFee do
    context 'validations' do
      it { should validate_absence_of(:warrant_issued_date) }
      it { should validate_absence_of(:warrant_executed_date) }
      it { should validate_absence_of(:sub_type_id) }
      it { should validate_absence_of(:case_numbers) }
    end
  end
end
