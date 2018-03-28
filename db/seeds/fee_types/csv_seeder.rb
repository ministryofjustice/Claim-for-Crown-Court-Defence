require_relative 'csv_row_mapper'

module Seeds
  module FeeTypes
    class CsvSeeder
      def initialize(dry_mode: true)
        @dry_mode = dry_mode.to_s.downcase.strip == 'true'
        @file_path = Rails.root.join('lib', 'assets', 'data', 'fee_types.csv')
      end

      def call
        data = CSV.read(file_path)
        data.shift

        reset_totals

        data.each do |row|
          process_row(row)
        end

        log "[OUTPUT] Created: #{total_created} | Updated: #{total_updated} | Error: #{total_with_error} | Total: #{total}", stdout: true
      end

      protected

      attr_accessor :total_created, :total_updated, :total_with_error, :total

      private

      attr_reader :file_path, :dry_mode

      def reset_totals
        self.total = 0
        self.total_created = 0
        self.total_updated = 0
        self.total_with_error = 0
      end

      def process_row(row)
        id, description, code, unique_code, max_amount, calculated, fee_type, roles, parent_id, quantity_is_decimal = row
        row_attributes = {
          id: id,
          description: description,
          code: code,
          unique_code: unique_code,
          max_amount: max_amount,
          calculated: calculated,
          fee_type: fee_type,
          roles: roles,
          quantity_is_decimal: quantity_is_decimal
        }
        klass = fee_type.constantize
        parent_id = parent_id.nil? ? nil : klass.find_by(description: parent_id.strip).try(:id)
        attributes = Seeds::FeeTypes::CsvRowMapper.call(row_attributes, parent_id)

        record = klass.find_by(id: id)
        if record
          log "[EXISTENT RECORD] Updating attributes: #{attributes.inspect}"
          record.update_attributes!(attributes) unless dry_mode
          self.total_updated += 1
        else
          log "[NEW RECORD] Creating with attributes: #{attributes.inspect}"
          klass.create!(attributes) unless dry_mode
          self.total_created += 1
        end
      rescue => err
        log "***************** #{err.class}  #{err.message} *********** #{__FILE__}::#{__LINE__} ***********\n"
        log err.backtrace
        log row
        self.total_with_error += 1
      ensure
        self.total += 1
      end

      def log(message, stdout: false)
        contents = dry_mode ? ['[DRY MODE]'] : []
        contents << message
        output = contents.join(' ')
        Rails.logger.info output
        puts output if stdout
      end
    end
  end
end
