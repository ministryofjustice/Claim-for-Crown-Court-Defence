module DataMigrator
  class OffenceCodeGenerator
    attr_reader :offence

    def initialize(offence)
      @offence = offence
    end

    def code(modifier = nil)
      offence.description.abbreviate +
        modifier.to_s +
        '_' +
        offence.offence_class.class_letter
    end
  end

  class OffenceUniqueCodeMigrator
    attr_reader :offences

    def initialize
      @offences = Offence.unscoped.order(:description)
      create_offence_set
    end

    def migrate!
      @offence_set.each do |code, details|
        sql = "UPDATE offences SET unique_code = \'#{code}\' WHERE id = #{details[:id]}"
        ap "executing #{sql} \# for #{details[:description]}"
        Offence.connection.execute sql
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

    private

    def unique_code(offence)
      generator = OffenceCodeGenerator.new(offence)
      code = generator.code

      modifier = nil
      code = generator.code(modifier.to_i + 1) while @offence_set.key?(code)
      code
    end
  end
end

class String
  def abbreviate(target_length = 6)
    words = clean_and_split_sentence
    acronym = first_word_char_or_chars(words, target_length)

    words.each do |word|
      acronym << first_char_or_number(word)
    end
    acronym.upcase
  end

  private

  def clean_and_split_sentence
    tr("\n", ' ')
      .squeeze("\s\t\n")
      .strip
      .split(/\s/)
  end

  def first_word_char_or_chars(words, target_length)
    if words.size < target_length
      chars_from_first_word = target_length - words.size
      words.shift[0..chars_from_first_word]
    else
      words.shift.chr
    end
  end

  def first_char_or_number(word)
    word =~ /\A\d+\z/ ? word : word.gsub(/\W+/, '').chr
  end
end
