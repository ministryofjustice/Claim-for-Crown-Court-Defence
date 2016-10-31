module StringExtension

  def zero?
    present? && to_f == 0.0
  end

  def true?
    (/(true|t|yes|y|1)$/i).match(to_s).present?
  end

  def false?
    to_s.strip.empty? || (/(false|f|no|n|0)$/i).match(to_s).present?
  end

  def to_bool
    return true if true?
    return false if false?
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end

  def alpha?
    !!match(/^[[:alpha:]]+$/)
  end

  def strftime(format)
    Time.zone.parse(self).strftime(format)
  end
end
