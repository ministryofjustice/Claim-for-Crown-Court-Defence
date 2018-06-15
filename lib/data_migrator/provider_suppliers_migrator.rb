require 'csv'

module DataMigrator
  class ProviderSuppliersMigrator
    def self.call(options = {})
      new(options).call
    end

    def initialize(options = {})
      @seed_file = options[:seed_file] || default_seed_file
      @dry_run = options[:dry_run].to_s.downcase.strip == 'true'
    end

    def call
      reset_totals
      CSV.foreach(seed_file, headers: true) do |row|
        process_row(row)
      end
      log("[OUTPUT] Total: #{total} | Not Found: #{total_not_found}| Updated: #{total_updated} | Not Updated: #{total_not_updated} | Error: #{total_errored}", stdout: true)
    end

    protected

    attr_accessor :total, :total_not_found, :total_updated, :total_not_updated, :total_errored

    private

    attr_reader :seed_file, :dry_run

    def default_seed_file
      File.join(Rails.root, 'db/data/providers.csv')
    end

    def reset_totals
      @total = 0
      @total_not_found = 0
      @total_updated = 0
      @total_not_updated = 0
      @total_errored = 0
    end

    def process_row(row)
      sn = SupplierNumber.find_by(supplier_number: row['account_number'])
      return not_found(row) unless sn
      return not_updated(row) if sn.postcode.present?
      update_record(sn, row)
    rescue StandardError => exception
      errored(exception)
    ensure
      self.total += 1
    end

    def not_updated(row)
      self.total_not_updated += 1
      log("[NOT UPDATED] Supplier with account number '#{row['account_number']}' already has a postcode set")
    end

    def update_record(supplier_number, row)
      supplier_number.update_attribute(:postcode, row['postcode']) unless dry_run
      self.total_updated += 1
      log("[UPDATED] Supplier with account number '#{row['account_number']}' updated with postcode #{row['postcode']}")
    end

    def not_found(row)
      self.total_not_found += 1
      log("[NOT FOUND] Supplier with account number '#{row['account_number']}' not found")
    end

    def errored(exception)
      log "[ERROR] #{exception.class} #{exception.message}"
      self.total_errored += 1
    end

    def log(message, stdout: false)
      log_parts = []
      log_parts << '[DRY RUN]' if dry_run
      log_parts << message
      output = log_parts.join(' ')
      Rails.logger.info output
      puts output if stdout
    end
  end
end
