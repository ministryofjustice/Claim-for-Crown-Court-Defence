require_relative 'offence_code_generator'

module DataMigrator
  class OffenceUniqueCodeMigrator
    attr_reader :offences, :offence_set

    class InappropriateRelation < StandardError; end

    def initialize(relation: nil)
      raise InappropriateRelation, "Inappropriate relation given: expected #{Offence}, got #{relation.klass}" unless relation.nil? || relation.klass.eql?(Offence)
      @offences = relation || Offence.unscoped.order(description: :asc)
      create_offence_set
    end

    def create_offence_set
      @offence_set = {}
      offences.each_with_object(@offence_set) do |offence, set|
        set[unique_code(offence)] = { id: offence.id, description: offence.description, unique_code: offence.unique_code, contrary: offence.contrary, band: offence.offence_band&.description, class_letter: offence.offence_class&.class_letter }
        set
      end
    end

    def migrate!
      puts '-- clearing existing offences.unique_code data'
      offences.update_all('unique_code = id')
      puts '-- updating offences.unique_code data'
      offence_set.each do |code, offence|
        sql = "UPDATE offences SET unique_code = \'#{code}\' WHERE id = #{offence[:id]}"
        @offences.connection.execute sql
      end
      puts "codes generated: #{offence_set.count}".green
      puts "unique codes generated: #{offence_set.keys.uniq.count}".green
    end

    def pretend(format: :text)
      offence_set.each do |code, offence|
        output(code, offence, format)
      end
      puts "codes generated: #{offence_set.count}"
      puts "unique codes generated: #{offence_set.keys.uniq.count}"
    end

    private

    def unique_code(offence)
      modifier = 0
      code = generator(offence).code
      code = generator.code(modifier += 1) while offence_set.key?(code)
      code
    end

    def generator(offence = nil)
      if offence
        @generator = OffenceCodeGenerator.new(offence)
      else
        @generator
      end
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    def output(code, offence, format)
      case format.downcase.to_sym
      when :sql
        puts "UPDATE offences SET unique_code = #{code} WHERE id = #{offence[:id]}".yellow
      when :diff
        puts offence[:description].concat("\n -#{offence[:unique_code]}".red).concat("\n +#{code} ".green) unless offence[:unique_code].eql?(code)
      when :csv
        puts [offence[:description], offence[:band] || offence[:class_letter], code].to_csv
      when :text
        puts "-- [would have] updated #{offence[:description]},#{offence[:band] || offence[:class_letter]}".white.concat(" unique_code: #{offence[:unique_code]} --> #{code}".green)
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity
  end
end
