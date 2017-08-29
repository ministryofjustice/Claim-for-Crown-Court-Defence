require_relative 'offence_code_generator'

module DataMigrator
  class OffenceUniqueCodeMigrator
    attr_reader :offences

    def initialize
      @offences = Offence.unscoped.order(:description)
      create_offence_set
    end

    def migrate!
      puts '-- updating offences.unique_code data'
      @offence_set.each do |code, details|
        sql = "UPDATE offences SET unique_code = \'#{code}\' WHERE id = #{details[:id]}"
        @offences.connection.execute sql
      end
    end

    def create_offence_set
      @offence_set = {}
      offences.each_with_object(@offence_set) do |offence, set|
        set[unique_code(offence)] = { id: offence.id, description: offence.description }
        set
      end
    end

    def test
      @offence_set.each do |code, details|
        ap "UPDATE offences SET unique_code = #{code} WHERE id = #{details[:id]} \# for #{details[:description]}"
      end
      puts "codes generated: #{@offence_set.count}"
      puts "unique codes generated: #{@offence_set.keys.uniq.count}"
    end

    def unique_code(offence)
      modifier = 0
      code = generator(offence).code
      code = generator.code(modifier += 1) while @offence_set.key?(code)
      code
    end

    def generator(offence = nil)
      if offence
        @generator = OffenceCodeGenerator.new(offence)
      else
        @generator
      end
    end
  end
end
