require 'csv'

module RakeHelpers
  class FeeTypeUniqueCodeAdder

    def initialize
      @rows = load_csv
    end

    def run
      @rows.each { |row|  update_fee_type(row) }
      puts "All fee types updated with unique code"
    end


    private

    def update_fee_type(row)
      id, description, code, unique_code, max_amount, calculated, fee_type, roles, parent_id, quantity_is_decimal = row
      klass = fee_type.constantize
      fee_type = klass.find(id)
      if fee_type.description != description
        puts "ERROR: Unexpected description for record id #{id}"
        puts "EXPECTED: #{description}"
        puts "GOT:      #{fee_type.description}"
        raise "Terminating"
      end
      fee_type.unique_code = unique_code
      fee_type.save!
    end

    def load_csv
      file_path = Rails.root.join('lib', 'assets', 'data', 'fee_types.csv')
      data = CSV.read(file_path)
      data.shift
      data
    end
  end
end