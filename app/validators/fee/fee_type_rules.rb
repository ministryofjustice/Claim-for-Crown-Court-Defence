module Fee
  class FeeTypeRules
    def initialize
      with_set_for_fee_type('MIUMU') do |set|
        set << Rule::Struct.new(:quantity, :equal, 1, 'miumu_numericality')
      end

      with_set_for_fee_type('MIUMO') do |set|
        set << Rule::Struct.new(:quantity, :min, 3, 'miumo_numericality')
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
  end
end
