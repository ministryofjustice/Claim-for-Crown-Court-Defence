module Claims
  class CalculateFee
    def self.call(options)
      new(options).call
    end

    def initialize(options = {})
      @options = options
      @supplier_type = options.fetch(:supplier_type)
      @case_date = options[:case_date]
      @fee_type_code = options.fetch(:fee_type_code)
      @advocate_category = options[:advocate_category]
      @offence_class = options[:offence_class]
      @number_of_days_attended = options[:number_of_days_attended]
      @number_of_cases = options[:number_of_cases]
      @number_of_defendants = options[:number_of_defendants]
      @trial_length = options[:trial_length]
      @number_of_prosecution_witnesses = options[:number_of_prosecution_witnesses]
      @pages_prosecution_evidence = options[:pages_prosecution_evidence]
    end

    def call
      # 1. Retrieve fee scheme [scheme_pk] base on supplier type (ADVOCATE or SOLICITOR)
      # 2. Retrieve fee type code (based on case type) [fee_type_code]
      # 3. Retrieve scenario (based on case type) [scenario]
      # 4.
      # - [OPTIONAL] Retrieve advocate type [advocate_type]
      # - [OPTIONAL] Retrieve offence class (if case type does not have fixed fee) [offence_class]
      # - Total days attendance (default 0) [day]
      # - Number of cases (default 1) [number_of_cases]
      # - Total number of defendants (default 1) [number_of_defendants]
      # - Trial length [trial_length]
      # 5. Calculate the total fee amount
      calculate_fee
    end

    private

    attr_reader :supplier_type, :case_date, :fee_type_code, :advocate_category, :options, :offence_class,
                :number_of_days_attended, :number_of_cases, :number_of_defendants, :trial_length,
                :number_of_prosecution_witnesses, :pages_prosecution_evidence, :case, :retrial_interval

    alias day number_of_days_attended
    alias pw number_of_prosecution_witnesses
    alias ppe pages_prosecution_evidence
    def optional_data
      %i[advocate_type offence_class day number_of_cases number_of_defendants trial_length pw ppe case retrial_interval]
    end

    def calculate_fee
      data = { fee_scheme_id: fee_scheme.id, fee_type_code: mapped_fee_type_code, scenario_id: scenario_identifier }

      optional_data.each do |optional_field|
        data[optional_field] = send(optional_field) if send(optional_field)
      end

      res = LAA::Fee.calculate(data)
      return unless res
      res.amount
    end

    def fee_scheme
      @fee_scheme ||= LAA::FeeScheme.find(
        supplier_type: supplier_type,
        case_date: case_date
      )
    end

    def mapped_fee_type_code
      # TODO: probably can use with some more centralised
      # location for the mappings
      # Also, atm, this is specific for CCR (does not include CCLF)
      res = [
        CCR::Fee::BasicFeeAdapter::BASIC_FEE_BILL_MAPPINGS,
        CCR::Fee::FixedFeeAdapter::FIXED_FEE_BILL_MAPPINGS,
        CCR::Fee::MiscFeeAdapter::MISC_FEE_BILL_MAPPINGS
      ].reduce(&:merge)[fee_type_code.to_sym]
      return unless res
      res[:bill_subtype]
    end

    def scenario_identifier
      # TODO: probably can use with some more centralised
      # location for the mappings
      # Also, atm, this is specific for CCR (does not include CCLF)
      res = CCR::CaseTypeAdapter::BILL_SCENARIOS[fee_type_code.to_sym]
      return unless res
      res[res.length - 2..res.length].to_i
    end

    def advocate_type
      # TODO: probably can use with some more centralised
      # location for the mappings
      # Also, atm, this is specific for CCR (does not include CCLF)
      CCR::AdvocateCategoryAdapter::TRANSLATION_TABLE[advocate_category]
    end
  end
end
