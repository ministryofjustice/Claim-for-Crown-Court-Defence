require 'csv'



# This class holds a collection of rules relating to TransferClaims which govern
# the fee name, the conclusion visibility, the validity of the data, and the
# case allocation type.  The rules are read in from a CSV file, instantiated into
# TransferDataItem objects and then added to this collection.
#
# Because reading the CSV file is a relatively expensive operation, and the data is
# static, this is a singleton class which gets instantiated once and once only.
#
# To get a reference to the object, call .instance rather than .new.
#
module Claim
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
      result =  @collection_hash[detail.litigator_type][detail.elected_case][detail.transfer_stage_id][detail.case_conclusion_id]
      result = @collection_hash[detail.litigator_type][detail.elected_case][detail.transfer_stage_id]['*'] if result.nil?
      result
    end

    def transfer_fee_full_name(detail)
      raise ArgumentError.new('Invalid combination of transfer detail fields') unless detail_valid?(detail)
      data_item_for(detail)[:transfer_fee_full_name]
    end

    def allocation_case_type(detail)
      raise ArgumentError.new('Invalid combination of transfer detail fields') unless detail_valid?(detail)
      data_item_for(detail)[:allocation_case_type]
    end

    def detail_valid?(detail)
      return false if detail.unpopulated?
      data_item = data_item_for(detail)
      return false if data_item.nil?
      data_item[:validity]
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