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

RSpec.describe Fee::MiscFee do
  it { should belong_to(:fee_type) }
  it { should validate_presence_of(:claim).with_message('blank') }
  it { should validate_presence_of(:fee_type).with_message('blank') }

  include_examples 'defendant uplift delegation'
  include_examples '.defendant_uplift_sums'
  include_examples 'duplicable fee'

  describe '#is_misc?' do
    it 'returns true' do
      expect(build(:misc_fee).is_misc?).to be true
    end
  end

  describe '#miumu_quantity' do
    let(:case_type) { create(:case_type, :trial) }
    let(:claim) { create(:advocate_claim, case_type: case_type) }
    let(:miumu) { create(:misc_fee_type, :miumu, id: 108) }
    let(:miumo) { create(:misc_fee_type, :miumo, id: 107) }
    
    context 'when fee_type_id = 108 (Unused materials upto 3 hours)' do
      let(:fee) { create(:misc_fee, fee_type: miumu, claim: claim, quantity: 3) }
      it 'sets quantity to 1' do
        expect(fee.quantity).to eq 1
      end
    end

    context 'when fee_type_id is not 108' do
      let(:fee) { create(:misc_fee, fee_type: miumo, claim: claim, quantity: 3) }
      it 'does not set quantity to 1' do
        expect(fee.quantity).to eq 3
      end
    end
  end
end
