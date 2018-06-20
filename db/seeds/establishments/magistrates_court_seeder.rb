module Seeds
  module Establishments
    class MagistratesCourtSeeder
      def self.call(options)
        new(options).call
      end

      def initialize(options = {})
        @seed_file = Rails.root.join('lib', 'assets', 'data', 'establishments', 'magistrates_courts.csv')
        @dry_run = options[:dry_run].to_s.downcase.strip == 'true'
      end

      def call
        reset_totals
        CSV.foreach(seed_file, headers: true) do |row|
          process_row(row)
        end
        log("[OUTPUT] Total: #{total} | Created: #{total_created}| Updated: #{total_updated} | Error: #{total_with_error}", stdout: true)
      end

      protected

      attr_accessor :total_created, :total_updated, :total_with_error, :total

      private

      attr_reader :seed_file, :dry_run

      def reset_totals
        self.total = 0
        self.total_created = 0
        self.total_updated = 0
        self.total_with_error = 0
      end

      def process_row(row)
        name = row['court_name_full']
        attributes = { postcode: row['postcode'] }
        establishment = Establishment.find_by(category: 'magistrates_court', name: name)
        return update_record(establishment, name, attributes) if establishment
        create_record(name, attributes)
      rescue StandardError => err
        log "[ERROR] Exception #{err.class} #{err.message}"
       self.total_with_error += 1
      ensure
        self.total += 1
      end

      def create_record(name, attributes)
        Establishment.create(attributes.merge(name: name, category: 'magistrates_court')) unless dry_run
        log "[CREATED] Created magistrate court with name '#{name}'"
        self.total_created += 1
      end

      def update_record(record, name, attributes)
        record.update(attributes) unless dry_run
        log "[UPDATED] Updated magistrate court with name '#{name}'"
        self.total_updated += 1
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
end
