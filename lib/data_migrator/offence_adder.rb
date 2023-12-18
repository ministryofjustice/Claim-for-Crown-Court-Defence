# Convenience class for creating or destroying
# an offence
# Example: add a new scheme 11 offence
#
# fee_scheme_11 = FeeScheme.where(version: 11).where(name: 'AGFS').first
# migrator = OffenceDataMigrator.new(
#   fee_scheme: fee_scheme_11,
#   offence_band: '17.1',
#   description: 'Aiding, abetting, causing or permitting dangerous driving',
#   contrary: 'Road Traffic Act 1988, s.2',
#   year_chapter: '1988 c. 52'
# )
# migrator.up
#
require_relative 'offence_code_generator'

module DataMigrator
  class OffenceAdder
    attr_reader :fee_scheme

    def initialize(fee_scheme:, description:, offence_band:, contrary:, year_chapter:)
      @fee_scheme = fee_scheme
      @description = description
      @offence_band = offence_band
      @contrary = contrary
      @year_chapter = year_chapter
    end

    def up
      offence = find_or_create_offence!(attributes)
      puts "-- found or created offence (#{offence.attributes})"
    end

    def down
      offence = offences_for_scheme.find_by(attributes).destroy
      puts "-- destroyed offence (#{offence.attributes})"
    end

    private

    def attributes
      {
        description:,
        offence_band:,
        contrary:,
        year_chapter:
      }
    end

    def create_offence!(attrs)
      attrs[:id] = offences_for_scheme.maximum(:id) + 1
      attrs[:unique_code] = SecureRandom.uuid

      offence = Offence.create!(attrs)
      OffenceFeeScheme.find_or_create_by(offence:, fee_scheme:)
      update_unique_code(offence)
      offence
    end

    def find_or_create_offence!(attrs)
      offence = offences_for_scheme.find_by(attrs)
      return offence if offence.present?
      create_offence!(attrs)
    end

    def description
      @description.strip
    end

    def offence_band
      OffenceBand.find_by(description: @offence_band)
    end

    def contrary
      @contrary&.strip
    end

    def year_chapter
      @year_chapter&.strip
    end

    def offences_for_scheme
      Offence
        .unscoped
        .joins(:offence_fee_schemes)
        .where(offence_fee_schemes: { fee_scheme_id: fee_scheme.id })
    end

    # unique_code has unique, not null contraint but cannot be given
    # expected value until all offences exist
    # - see DataMigrator::OffenceUniqueCodeMigrator
    def update_unique_code(offence)
      code = generator(offence).code
      modifier = 0
      code = generator.code(modifier += 1) until offence.update(unique_code: code)
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
