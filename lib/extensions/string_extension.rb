module StringExtension
  def zero?
    present? && to_f == 0.0
  end

  def true?
    /(true|t|yes|y|1)$/i.match(to_s).present?
  end

  def false?
    to_s.strip.empty? || /(false|f|no|n|0)$/i.match(to_s).present?
  end

  def to_bool
    return true if true?
    return false if false?
    raise ArgumentError, "invalid value for Boolean: \"#{self}\""
  end

  def alpha?
    !match(/^[[:alpha:]]+$/).nil?
  end

  def digit?
    !match(/^[[:digit:]]+$/).nil?
  end

  def strftime(format)
    Time.zone.parse(self).strftime(format)
  end

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
    word.match?(/\A\d+\z/) ? word : word.gsub(/\W+/, '').chr
  end
end
