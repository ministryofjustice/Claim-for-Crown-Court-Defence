module Fee
  class FeeTypeRules
    def initialize
      with_set_for_fee_type('MIUMU') do |set|
        set << add_rule(:quantity, :equal, 1, message: 'miumu_numericality')
        set << add_rule(*graduated_fee_type_only_rule)
      end

      with_set_for_fee_type('MIUMO') do |set|
        set << add_rule(:quantity, :min, 3.01, message: 'miumo_numericality')
        set << add_rule(*graduated_fee_type_only_rule)
      end

      with_set_for_fee_type('MIPHC') do |set|
        set << add_rule('claim.offence.offence_band.offence_category.number',
                        :exclusion,
                        [1, 6, 9],
                        message: 'offence_category_exclusion',
                        attribute_for_error: :fee_type)
      end
    end

    attr_reader :sets

    def self.all
      new.sets
    end

    def self.where(unique_code:)
      all.select { |rs| rs.object&.unique_code.eql?(unique_code) }
    end

    private

    def with_set_for_fee_type(unique_code)
      @sets ||= []
      fee_type = Fee::BaseFeeType.find_by(unique_code: unique_code)
      set = Rule::Set.new(fee_type)
      yield set
      @sets << set
    end

    def add_rule(*args)
      Rule::Struct.new(*args)
    end

    def graduated_fee_type_only_rule
      @graduated_fee_type_only_rule ||= \
        ['claim.case_type_id',
         :inclusion,
         CaseType.not_fixed_fee.ids,
         message: 'case_type_inclusion',
         attribute_for_error: :fee_type,
         allow_nil: true]
    end
  end
end
