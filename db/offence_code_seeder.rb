  class OffenceCodeSeeder
    attr_reader :description, :class_letter

    def initialize(description, class_letter)
      @description = description
      @class_letter = class_letter
    end

    def unique_code
      modifier = 0
      unique_code = code
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
      Offence.where(unique_code: code).
        where.not(description: description).
        present?
    end
  end
