require 'csv'

# This class holds a collection of rules relating to TransferClaims which govern
# the fee name, the validity of the data, and the
# case allocation type. The rules are read in from a CSV file, instantiated into
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
    include TransferDataItemDelegatable

    def initialize
      load_data_items
      @collection_hash = construct_collection_hash
    end

    data_item_delegate :transfer_fee_full_name, :allocation_type, :bill_scenario, :ppe_required, :days_claimable

    def to_h
      @collection_hash
    end

    def to_json(opts = nil)
      @collection_hash.to_json(opts)
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
        result_hash.each_value do |result|
          ids << transfer_stage_id if result[:validity] == true
        end
      end
      ids.uniq.sort
    end

    def valid_case_conclusion_ids(litigator_type, elected_case, transfer_stage_id)
      result = @collection_hash.fetch(litigator_type).fetch(elected_case).fetch(transfer_stage_id).keys
      result = TransferBrain.case_conclusion_ids if result == ['*']
      result.sort
    end

    def data_item_for(detail)
      specific_mapping_for(detail) || wildcard_mapping_for(detail)
    end

    private

    def specific_mapping_for(detail)
      @collection_hash.dig(
        detail.litigator_type,
        detail.elected_case,
        detail.transfer_stage_id,
        detail.case_conclusion_id
      )
    end

    def wildcard_mapping_for(detail)
      @collection_hash.dig(
        detail.litigator_type,
        detail.elected_case,
        detail.transfer_stage_id,
        '*'
      )
    end

    def read_csv
      file = Rails.root.join('config', 'transfer_brain_data_items.csv')
      csv_content = File.read(file)
      CSV.parse(csv_content, headers: true)
    end

    def parse_data_items(data_items)
      data_items.each_with_object([]) do |data_item, arr|
        arr << TransferBrainDataItem.new(data_item)
      end
    end

    def load_data_items
      csv = read_csv
      attributes = csv.headers.map(&:to_sym)
      klass = Struct.new('DataItem', *attributes)

      data_items = csv.each_with_object([]) do |row, arr|
        arr << klass.new(*row.to_hash.values)
      end

      @data_items = parse_data_items(data_items)
    end

    def construct_collection_hash
      @data_items.each_with_object({}) do |item, collection_hash|
        collection_hash.deep_merge!(item.to_h)
      end
    end
  end
end
