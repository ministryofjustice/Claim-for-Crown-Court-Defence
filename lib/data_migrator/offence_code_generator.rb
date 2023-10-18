module DataMigrator
  class OffenceCodeGenerator
    attr_reader :offence

    def initialize(offence)
      Offence.include OffenceExtensions
      @offence = offence
    end

    def code(modifier = nil)
      offence.generated_unique_code(modifier)
    end
  end
end

module OffenceExtensions
  attr_reader :modifier

  def generated_unique_code(modifier = nil)
    @modifier = modifier
    if offence_class
      scheme_9_offence_unique_code
    elsif offence_band
      scheme_10_plus_offence_unique_code
    end
  end

  def scheme_9_offence_unique_code
    description.abbreviate +
      modifier.to_s +
      '_' +
      offence_class.class_letter
  end

  def scheme_10_plus_offence_unique_code
    description.abbreviate +
      modifier.to_s +
      '_' +
      offence_band.description +
      gt_10_offence_code_suffix
  end

  def gt_10_offence_code_suffix
    fee_scheme = fee_schemes.find { |fs| fs.name.eql?('AGFS') }
    if fee_scheme&.version && fee_scheme.version > 10
      '~' + fee_scheme.version.to_s
    else
      ''
    end
  end
end
