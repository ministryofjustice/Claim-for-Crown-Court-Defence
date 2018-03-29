module Seeds
  module FeeTypes
    class CsvRowMapper
      def self.call(row_attrs, parent_id)
        new(row_attrs, parent_id).to_h
      end

      def initialize(row_attrs, parent_id)
        @row_attrs = row_attrs
        @parent_id = parent_id
      end

      def to_h
        {
          id: primary_key,
          description: row_attrs.fetch(:description),
          code: row_attrs.fetch(:code),
          unique_code: row_attrs.fetch(:unique_code),
          max_amount: mapped_max_amount,
          calculated: mapped_calculated,
          type: row_attrs.fetch(:fee_type),
          parent_id: parent_id,
          roles: mapped_roles,
          quantity_is_decimal: row_attrs.fetch(:quantity_is_decimal),
          position: mapped_position
        }
      end

      private

      attr_reader :row_attrs, :parent_id

      def primary_key
        row_attrs.fetch(:id)
      end

      def mapped_roles
        row_attrs.fetch(:roles).split(';')
      end

      def mapped_calculated
        row_attrs.fetch(:calculated).to_s.downcase.strip == 'true'
      end

      def max_amount
        row_attrs.fetch(:max_amount)
      end

      def mapped_max_amount
        return if max_amount.to_s.strip.blank?
        max_amount
      end

      def mapped_position
        row_attrs[:position] || primary_key
      end
    end
  end
end
