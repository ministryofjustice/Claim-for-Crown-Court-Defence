  class OffenceCodeSeederSchemeTen
    attr_reader :description, :class_letter, :contrary_to

    def initialize(description, class_letter, contrary_to)
      @description = description
      @class_letter = class_letter
      @contrary_to = contrary_to
    end

    def unique_code
      modifier = 0
      unique_code = code
      binding.pry if unique_code == 'RAPE_49'
      unique_code = code(modifier += 1) while exists?(unique_code)
      unique_code
    end

    private

    def code(modifier = nil)
      code = description.abbreviate +
        modifier.to_s +
        '_' +
        class_letter
    end

    def exists?(code)
      Offence.where(unique_code: code).present?
    end
  end
