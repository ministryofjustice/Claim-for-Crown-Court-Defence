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
  class TransferBrain
    class DataItemCollection
      include Singleton
      include DataItemDelegatable

      data_item_delegate :transfer_fee_full_name, :allocation_type, :bill_scenario, :ppe_required, :days_claimable

      def detail_valid?(detail)
        return false if detail.unpopulated?
        data_item = data_item_for(detail)
        return false if data_item.nil?
        data_item.validity
      end

      def valid_transfer_stage_ids(litigator_type, elected_case)
        valid_data_items = data_items.select do |item|
          item.litigator_type == litigator_type &&
            item.elected_case == elected_case &&
            item.validity
        end
        ids = valid_data_items.map(&:transfer_stage_id)
        ids.uniq.sort
      end

      def valid_case_conclusion_ids(litigator_type, elected_case, transfer_stage_id)
        result = data_items.select do |item|
          item.litigator_type == litigator_type &&
            item.elected_case == elected_case &&
            item.transfer_stage_id == transfer_stage_id
        end.map(&:case_conclusion_id)
        result = TransferBrain.case_conclusion_ids if result == ['*']
        result.sort
      end

      def data_item_for(detail)
        seek = DataItem.new(detail.slice(:litigator_type, :elected_case, :transfer_stage_id, :case_conclusion, :claim))
        # TODO: Log this (or remove completely) instead of raising an error
        raise 'Too many' if data_items.many? { |item| item == seek }
        data_items.find { |item| item == seek }
      end

      private

      def csv
        @csv ||= begin
          file = Rails.root.join('config', 'transfer_brain_data_items.csv')
          csv_content = File.read(file)
          CSV.parse(csv_content, headers: true)
        end
      end

      def data_items
        @data_items ||= csv.map { |row| TransferBrain::DataItem.new(**row) }
      end
    end
  end
end
