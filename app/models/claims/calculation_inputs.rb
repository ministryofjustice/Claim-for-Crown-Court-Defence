module Claims
  class CalculationInputs
    class << self
      def for(claim)
        new(claim)
      end
    end

    def initialize(claim)
      @claim = claim
    end

    def to_h
      {
        supplier_type: supplier_type,
        fee_type_code: fee_type_code,
        case_date: case_date,
        trial_length: trial_length,
        number_of_defendants: number_of_defendants,
        number_of_cases: number_of_cases,
        advocate_category: advocate_category,
        offence_class: offence_class,
        number_of_days_attended: number_of_days_attended,
        number_of_prosecution_witnesses: number_of_prosecution_witnesses,
        pages_prosecution_evidence: pages_prosecution_evidence
      }
    end

    private

    attr_reader :claim

    def supplier_type
      claim.external_user_type == :advocate ? 'ADVOCATE' : 'SOLICITOR'
    end

    def fee_type_code
      claim.case_type&.fee_type_code
    end

    def case_date
      claim.first_day_of_trial&.to_s(:db)
    end

    def trial_length
      claim.actual_trial_length
    end

    def number_of_defendants
      claim.defendants.count
    end

    def number_of_cases
      # TODO: change to a dynamic value if necessary
      # for now it will default to 1
      res = claim.fees&.where(fee_types: { code: 'NOC' })&.sum(:quantity)&.to_i
      [1, res].max
    end

    def advocate_category
      claim.advocate_category
    end

    def offence_class
      claim.offence&.offence_class&.class_letter
    end

    def number_of_days_attended
      # TODO: might required some input data
      # This should just be the total amount of days
      # The API should be able to apply the different types
      # of fees for each segment
      # existent fee codes for different daily attendances: SAF, DAJ, DAH, DAF
      1
    end

    def number_of_prosecution_witnesses
      claim.fees&.where(fee_types: { code: 'NPW' })&.sum(:quantity)&.to_i
    end

    def pages_prosecution_evidence
      claim.fees&.where(fee_types: { code: 'PPE' })&.sum(:quantity)&.to_i
    end
  end
end
