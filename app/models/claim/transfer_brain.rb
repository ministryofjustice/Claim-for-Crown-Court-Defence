
# This class holds only static methods to help with
# validation, determining visibility, the full fee name and the case
# allocation type for a TransferClaim.
#

module Claim
  class TransferBrain

    TRANSFER_STAGES = {
      10 => 'Up to and including PCMH transfer',
      20 => 'Before trial transfer',
      30 => 'During trial transfer',
      40 => 'Transfer after trial and before sentence hearing',
      50 => 'Transfer before retrial',
      60 => 'Transfer during retrial',
      70 => 'Transfer after retrial and before sentence hearing',
    }

    CASE_CONCLUSIONS = {
      10 => 'Trial',
      20 => 'Retrial',
      30 => 'Cracked',
      40 => 'Cracked before retrial',
      50 => 'Guilty plea'
    }



    def self.transfer_stage_by_id(id)
      name = TRANSFER_STAGES[id]
      raise ArgumentError.new "No such transfer stage id: #{id}" if name.nil?
      name
    end

    def self.transfer_stage_id(name)
      id = TRANSFER_STAGES.key(name)
      raise ArgumentError.new "No such transfer stage: '#{name}'" if id.nil?
      id
    end

    def self.transfer_stage_ids
      TRANSFER_STAGES.keys
    end

    def self.case_conclusion_by_id(id)
      name = CASE_CONCLUSIONS[id]
      raise ArgumentError.new "No such case conclusion id: #{id}" if name.nil?
      name
    end

    def self.case_conclusion_id(name)
      id = CASE_CONCLUSIONS.key(name)
      raise ArgumentError.new "No such case conclusion: '#{name}'" if id.nil?
      id
    end

    def self.case_conclusion_ids
      CASE_CONCLUSIONS.keys
    end

    def self.details_combo_valid?(detail)
      TransferBrainDataItemCollection.instance.detail_valid?(detail) unless detail.errors?
    end

    def self.data_attributes
      TransferBrainDataItemCollection.instance.to_json.chomp
    end

    def self.allocation_type(detail)
      TransferBrainDataItemCollection.instance.allocation_type(detail)
    end

    def self.transfer_detail_summary(detail)
      TransferBrainDataItemCollection.instance.transfer_fee_full_name(detail)
    end

  end
end
