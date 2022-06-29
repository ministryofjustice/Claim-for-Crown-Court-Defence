# This class holds only static methods to help with
# validation, determining visibility, the full fee name and the case
# allocation type for a TransferClaim.
#

module Claim
  class TransferBrain
    include DataItemCollectionDelegatable

    Struct.new('TransferStage', :id, :description, :requires_case_conclusion)

    TRANSFER_STAGES = {
      10 => Struct::TransferStage.new(10, 'Up to and including PCMH transfer', true),
      20 => Struct::TransferStage.new(20, 'Before trial transfer', true),
      30 => Struct::TransferStage.new(30, 'During trial transfer', true),
      40 => Struct::TransferStage.new(40, 'Transfer after trial and before sentence hearing', false),
      50 => Struct::TransferStage.new(50, 'Transfer before retrial', true),
      60 => Struct::TransferStage.new(60, 'Transfer during retrial', true),
      70 => Struct::TransferStage.new(70, 'Transfer after retrial and before sentence hearing', false)
    }.freeze

    CASE_CONCLUSIONS = {
      10 => 'Trial',
      20 => 'Retrial',
      30 => 'Cracked',
      40 => 'Cracked before retrial',
      50 => 'Guilty plea'
    }.freeze

    data_item_collection_delegate :allocation_type, :bill_scenario, :ppe_required, :days_claimable

    def self.transfer_detail_summary(detail)
      TransferBrain::DataItemCollection.instance.transfer_fee_full_name(detail)
    end

    def self.transfer_stage_by_id(id)
      name = TRANSFER_STAGES[id]
      raise ArgumentError, "No such transfer stage id: #{id}" if name.nil?
      name
    end

    def self.transfer_stage_id(description)
      transfer_stage = TRANSFER_STAGES.values.detect { |ts| ts.description == description }
      raise ArgumentError, "No such transfer stage: '#{description}'" if transfer_stage.nil?
      transfer_stage.id
    end

    def self.transfer_stage_ids
      TRANSFER_STAGES.keys
    end

    def self.transfer_stage(detail)
      TRANSFER_STAGES[detail.transfer_stage_id]
    end

    def self.case_conclusion_by_id(id)
      name = CASE_CONCLUSIONS[id]
      raise ArgumentError, "No such case conclusion id: #{id}" if name.nil?
      name
    end

    def self.case_conclusion_id(name)
      id = CASE_CONCLUSIONS.key(name)
      raise ArgumentError, "No such case conclusion: '#{name}'" if id.nil?
      id
    end

    def self.case_conclusion_ids
      CASE_CONCLUSIONS.keys
    end

    def self.case_conclusion(detail)
      CASE_CONCLUSIONS[detail.case_conclusion_id]
    end

    def self.details_combo_valid?(detail)
      TransferBrain::DataItemCollection.instance.detail_valid?(detail) unless detail.errors?
    end

    def self.data_attributes
      TransferBrain::DataItemCollection.instance.to_json.chomp
    end

    #
    # only new litigators that transfered onto unelected cases at specific stages
    # are required to specify case conclusions.
    # i.e. 'new', false, [10,20,30,50,60]
    def self.case_conclusion_required?(detail)
      if detail&.transfer_stage_id.nil?
        false
      else
        detail.litigator_type == 'new' &&
          detail.elected_case == false && # treat nil as failure i.e. non-false
          TRANSFER_STAGES[detail.transfer_stage_id].requires_case_conclusion
      end
    end
  end
end
