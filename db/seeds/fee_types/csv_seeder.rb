require_relative 'csv_row_mapper'

module Seeds
  module FeeTypes
    class CsvSeeder
      def initialize(dry_mode: true, stdout: false)
        @stdout = stdout
        @dry_mode = dry_mode.to_s.downcase.strip == 'true'
        @file_path = Rails.root.join('lib', 'assets', 'data', 'fee_types.csv')
      end

      attr_reader :stdout

      def call
        data = CSV.read(file_path)
        data.shift

        reset_totals

        data.each do |row|
          process_row(row)
        end

        log "Created: #{total_created} | Updated: #{total_updated} | Error: #{total_with_error} | Processed: #{total}".yellow
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
        id, description, code, unique_code, max_amount, calculated, fee_type, roles, parent_id, quantity_is_decimal, position = row
        row_attributes = {
          id: id,
          description: description,
          code: code,
          unique_code: unique_code,
          max_amount: max_amount,
          calculated: calculated,
          fee_type: fee_type,
          roles: roles,
          quantity_is_decimal: quantity_is_decimal,
          position: position
        }
        klass = fee_type.constantize
        parent_id = parent_id.nil? ? nil : klass.find_by(description: parent_id.strip).try(:id)
        attributes = Seeds::FeeTypes::CsvRowMapper.call(row_attributes, parent_id)

        record = klass.find_by(id: id)
        if record
          current_attributes = record.attributes.except('created_at', 'updated_at').symbolize_keys
          new_attributes = attributes.symbolize_keys
          return if current_attributes.eql?(new_attributes)

          log "Updating: #{record.description}".yellow
          log "Attribute Diff: #{Hashdiff.diff(current_attributes, new_attributes)}".yellow
          record.update_attributes!(attributes) unless dry_mode
          self.total_updated += 1
        else
          log "Creating with attributes: #{attributes.inspect}"
          klass.create!(attributes) unless dry_mode
          self.total_created += 1
        end
      rescue => err
        log "***************** #{err.class} #{err.message} *********** #{__FILE__}::#{__LINE__} ***********\n"
        log err.backtrace
        log row
        self.total_with_error += 1
      ensure
        self.total += 1
      end

      def log(message)
        contents = dry_mode ? ['[DRY MODE]'] : []
        contents << message
        output = contents.join(' ')
        Rails.logger.info output
        puts output if stdout
      end
    end
  end
end
