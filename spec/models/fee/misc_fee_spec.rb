require 'rails_helper'

module Fee
  describe MiscFee do 
    it { should belong_to(:fee_type) }

    it { should validate_presence_of(:claim).with_message('blank') }
    
    it { should validate_presence_of(:fee_type).with_message('blank') }
  end
end