require_relative 'offence_code_generator'

module DataMigrator
  class OffenceUniqueCodeMigrator
    attr_reader :offences, :offence_set

    class InappropriateRelation < StandardError; end

    def initialize(relation: nil, stdout: false)
      unless relation.nil? || relation.klass.eql?(Offence)
        raise InappropriateRelation, "Inappropriate relation given: expected #{Offence}, got #{relation.klass}"
      end

      @stdout = stdout
      @offences = relation || Offence.unscoped.order(description: :asc)
      create_offence_set
    end

    def create_offence_set
      @offence_set = {}
      offences.each_with_object(@offence_set) do |offence, set|
        set[unique_code(offence)] = {
          id: offence.id,
          description: offence.description,
          unique_code: offence.unique_code,
          contrary: offence.contrary,
          band: offence.offence_band&.description,
          class_letter: offence.offence_class&.class_letter
        }
        set
      end
    end

    def migrate!
      out '-- clearing existing offences.unique_code data'
      offences.update_all('unique_code = id')
      out '-- updating offences.unique_code data'
      offence_set.each do |code, offence|
        sql = "UPDATE offences SET unique_code = '#{code}' WHERE id = #{offence[:id]}"
        @offences.connection.execute sql
      end
      out "codes generated: #{offence_set.count}".green
      out "unique codes generated: #{offence_set.keys.uniq.count}".green
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

    def out(string)
      puts string if @stdout
    end

    def output(code, offence, format)
      case format.downcase.to_sym
      when :sql
        puts "UPDATE offences SET unique_code = #{code} WHERE id = #{offence[:id]}".yellow
      when :diff
        unless offence[:unique_code].eql?(code)
          puts offence[:description].concat("\n -#{offence[:unique_code]}".red).concat("\n +#{code} ".green)
        end
      when :csv
        puts [offence[:description], offence[:band] || offence[:class_letter], code].to_csv
      when :text
        puts "-- [would have] updated #{offence[:description]},#{offence[:band] || offence[:class_letter]}".white.concat(" unique_code: #{offence[:unique_code]} --> #{code}".green)
      end
    end
  end
end
