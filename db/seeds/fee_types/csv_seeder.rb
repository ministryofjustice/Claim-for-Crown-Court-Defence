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
        total = 0
        total_created = 0
        total_updated = 0

        data.each do |row|
          begin
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
              total += 1
              total_updated += 1
            else
              log "[NEW RECORD] Creating with attributes: #{attributes.inspect}"
              klass.create!(attributes) unless dry_mode
              total += 1
              total_created += 1
            end
          rescue => err
            log "***************** #{err.class}  #{err.message} *********** #{__FILE__}::#{__LINE__} ***********\n"
            log err.backtrace
            log row
          end
          log "[OUTPUT] Created: #{total_created} | Updated: #{total_updated} | Total: #{total}"
        end
      end

      private

      attr_reader :file_path, :dry_mode

      def log(message)
        contents = dry_mode ? ['[DRY MODE]'] : []
        contents << message
        Rails.logger.info contents.join(' ')
      end
    end
  end
end
