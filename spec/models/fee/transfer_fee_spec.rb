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

