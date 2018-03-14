module Claim
  class TransferBrainDataItem
    def initialize(data_item)
      @litigator_type = data_item.litigator_type.downcase
      @elected_case = data_item.elected_case.to_bool
      @transfer_stage_id = TransferBrain.transfer_stage_id(data_item.transfer_stage)
      @case_conclusion_id = get_case_conclusion_id(data_item.conclusion)
      @validity = data_item.valid.to_bool
      @transfer_fee_full_name = data_item.transfer_fee_full_name
      @allocation_type = data_item.allocation_type
      @bill_scenario = data_item.bill_scenario
      @ppe_required = data_item.ppe_required
    end

    def to_h
      {
        @litigator_type => {
          @elected_case => {
            @transfer_stage_id => {
              @case_conclusion_id => {
                validity: @validity,
                transfer_fee_full_name: @transfer_fee_full_name,
                allocation_type: @allocation_type,
                bill_scenario: @bill_scenario,
                ppe_required: @ppe_required
              }
            }
          }
        }
      }
    end

    private

    def get_case_conclusion_id(item)
      item.blank? ? '*' : TransferBrain.case_conclusion_id(item)
    end
  end
end
