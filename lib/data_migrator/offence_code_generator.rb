class OffenceCodeGenerator
  attr_reader :offence

  def initialize(offence)
    Offence.send(:include, OffenceExtensions)
    @offence = offence
  end

  def code(modifier = nil)
    offence.generated_unique_code(modifier)
  end
end

module OffenceExtensions
  attr_reader :modifier

  def generated_unique_code(modifier = nil)
    @modifier = modifier
    if offence_class
      scheme_9_offence_unique_code
    elsif offence_band
      scheme_10_offence_unique_code
    end
  end

  def scheme_9_offence_unique_code
    description.abbreviate +
      modifier.to_s +
      '_' +
      offence_class.class_letter
  end

  def scheme_10_offence_unique_code
    description.abbreviate +
      modifier.to_s +
      '_' +
      offence_band.description
  end
end
