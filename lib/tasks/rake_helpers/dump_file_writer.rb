# frozen_string_literal: true

# name: DumpFileWriter
# help with writing database data
# to dump file.
#
# Performs custom logic such as type casting
# data and appends output to the given file.
#

module Tasks
  module RakeHelpers
    class DumpFileWriter
      attr_reader :table, :file_name, :data, :type_caster
      attr_accessor :model

      def initialize(file_name)
        @model = nil
        @file_name = file_name || File.join('tmp', 'anonymised_data.sql')
      end

      def model=(model)
        @model = model
        @table = model.class.arel_table
        @type_caster = table.send(:type_caster)
        @data = type_cast(extract_data)
      end

      def write
        raise ArgumentError, 'Model is nil, set model before write' if model.nil?
        open(file_name, 'a') do |file|
          file.puts prepare_sql
        end
      end

      private

      def type_cast(data)
        data.each do |attribute, value|
          data[attribute] = type_caster.type_cast_for_database(attribute.name, value)
        end
      end

      def extract_data
        column_names = model.class.column_names
        attribute_names = extract_attribute_names(column_names)
        add_values(attribute_names)
      end

      def add_values(attribute_names)
        attrs = {}
        attribute_names.each do |name|
          attrs[table[name]] = model._read_attribute(name)
        end
        attrs
      end

      def prepare_sql
        Arel::InsertManager.new(table).insert(data).to_sql + ';'
      end

      def extract_attribute_names(column_names)
        # note attributes_for_creater is a private method
        # therefore not great to depend on.
        # call to it extracted here for later refactor.
        model.send(:attributes_for_create, column_names)
      end
    end
  end
end
