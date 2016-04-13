# == Schema Information
#
# Table name: fee_types
#
#  id          :integer          not null, primary key
#  description :string
#  code        :string
#  created_at  :datetime
#  updated_at  :datetime
#  max_amount  :decimal(, )
#  calculated  :boolean          default(TRUE)
#  type        :string
#  roles       :string
#  parent_id   :integer
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

    describe '#has_dates_attended?' do
      it 'returns false' do
        expect(build(:fixed_fee_type).has_dates_attended?).to be false
        expect(build(:misc_fee_type).has_dates_attended?).to be false
      end
    end

  end

end
