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
