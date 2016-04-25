module Claim
  class TransferBrainDataItem

    attr_reader :litigator_type, :elected_case, :transfer_stage_id, :case_conclusion_id,
                :allocation_case_type, :visibility, :transfer_fee_full_name

    def initialize(arry)
      copy_array = arry
      begin
        @litigator_type           = arry.shift.downcase
        @elected_case             = arry.shift.to_bool
        @transfer_stage_id        = TransferBrain.transfer_stage_id(arry.shift)
        @case_conclusion_id       = get_case_conclusion_id(arry.shift)
        @validity                 = arry.shift.to_bool
        @visibility               = get_visibility(arry.shift)
        @transfer_fee_full_name   = arry.shift
        @allocation_case_type     = arry.shift
      rescue => err
        puts "#{err.class}: #{err.message}"
        ap copy_array
        raise 'Boom'
      end

    end

    def match_detail?(detail)
      @litigator_type == detail.litigator_type &&
          @elected_case == detail.elected_case &&
          @transfer_stage_id == detail.transfer_stage_id &&
          @case_conclusion_id == detail.case_conclusion_id
    end


    def to_h
      {
        @litigator_type => {
          @elected_case => {
            @transfer_stage_id => {
              @case_conclusion_id => {
                :visibility => @visibility,
                :validity => @validity,
                :transfer_fee_full_name => @transfer_fee_full_name,
                :allocation_case_type => @allocation_case_type
              }
            }
          }
        }
      }
    end

    private

    def get_case_conclusion_id(item)
      item.blank? ? '*' :  TransferBrain.case_conclusion_id(item)
    end

    def get_visibility(item)
      item.blank? ? false : item.to_bool
    end

  end
end
