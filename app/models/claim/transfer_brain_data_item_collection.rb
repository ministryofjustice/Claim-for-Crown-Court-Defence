require 'csv'

# This class holds a collection of rules relating to TransferClaims which govern
# the fee name, the validity of the data, and the
# case allocation type.  The rules are read in from a CSV file, instantiated into
# TransferDataItem objects and then added to this collection.
#
# Because reading the CSV file is a relatively expensive operation, and the data is
# static, this is a singleton class which gets instantiated once and once only.
#
# To get a reference to the object, call .instance rather than .new.
#
module Claim
  class InvalidTransferCombinationError < ArgumentError
    DEFAULT_MSG = 'Invalid combination of transfer detail fields'

    def initialize(msg=DEFAULT_MSG)
      super(msg)
    end
  end

  class TransferBrainDataItemCollection
    include Singleton

    def initialize
      lines = load_file
      @collection = []
      lines.each { |line| @collection << TransferBrainDataItem.new(line) }
      @collection_hash = construct_collection_hash
    end

    # Returns a hierarchical hash of the collection with the keys litigator_type -> elected_case -> transfer_stage_id -> case_conclusion_id.
    # In the resulting hash, '*' in the case_conclusion_id key means any case conclusion id
    def to_h
      @collection_hash
    end

    def to_json
      @collection_hash.to_json
    end

    def data_item_for(detail)
      begin
        result = @collection_hash.fetch(detail.litigator_type).fetch(detail.elected_case).fetch(detail.transfer_stage_id)[detail.case_conclusion_id]
        result = @collection_hash.fetch(detail.litigator_type).fetch(detail.elected_case).fetch(detail.transfer_stage_id).fetch('*') if result.nil?
      rescue KeyError
        result = nil
      end
      result
    end

    def transfer_fee_full_name(detail)
      raise InvalidTransferCombinationError.new unless detail_valid?(detail)
      data_item_for(detail)[:transfer_fee_full_name]
    end

    def allocation_type(detail)
      raise InvalidTransferCombinationError.new unless detail_valid?(detail)
      data_item_for(detail)[:allocation_type]
    end

    def detail_valid?(detail)
      return false if detail.unpopulated?
      data_item = data_item_for(detail)
      return false if data_item.nil?
      data_item[:validity]
    end

    def valid_transfer_stage_ids(litigator_type, elected_case)
      transfer_stages = @collection_hash.fetch(litigator_type).fetch(elected_case)
      ids = []
      transfer_stages.each do |transfer_stage_id, result_hash|
        result_hash.each do |_case_conclusion_id, result|
          ids << transfer_stage_id if result[:validity] == true
        end
      end
      ids.uniq.sort
    end

    def valid_case_conclusion_ids(litigator_type, elected_case, transfer_stage_id)
      result = @collection_hash.fetch(litigator_type).fetch(elected_case).fetch(transfer_stage_id).keys
      result = TransferBrain.case_conclusion_ids if result ==  ['*']
      result.sort
    end

    private

    def load_file
      filename = File.join(Rails.root, 'config', 'transfer_brain_data_items.csv')
      lines = CSV.read filename
      lines.shift       # remove header line
      lines
    end

    def construct_collection_hash
      collection_hash = {}
      @collection.each do |item|
        collection_hash.deep_merge!(item.to_h)
      end
      collection_hash
    end
  end
end
