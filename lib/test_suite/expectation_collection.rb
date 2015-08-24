module TestSuite
  class ExpectationCollection
    
    def self.default
      raise NotImplementedError, '#default factory method must be implemented by subclasses'
    end

    def map_to_assertions
      @all.map { |expectation| Assertion.new(expectation) }
    end

    protected

    Expectation = Struct.new(:function, :result)

    def initialize(expectations)
      @all = expectations.map { |func, result| Expectation.new(func, result) }
    end

    def self.parse(activerecord_collection)
      ApiClient::PARSER.parse(MultiJson.dump(activerecord_collection))
    end
  end

  class ApiInfoExpectations < ExpectationCollection
    def self.default
      new([
        [ lambda { ApiClient::Info.case_types },              Settings.case_types ],
        [ lambda { ApiClient::Info.courts },                  parse(Court.all) ],
        [ lambda { ApiClient::Info.advocate_categories },     Settings.advocate_categories ],
        [ lambda { ApiClient::Info.prosecuting_authorities }, Settings.prosecuting_authorities ],
        [ lambda { ApiClient::Info.trial_cracked_at_thirds }, Settings.trial_cracked_at_third ],
        [ lambda { ApiClient::Info.granting_body_types },     Settings.court_types ],
        [ lambda { ApiClient::Info.offence_classes },         parse(OffenceClass.all) ],
        [ lambda { ApiClient::Info.offences },                parse(Offence.all) ],
        [ lambda { ApiClient::Info.fee_categories },          parse(FeeCategory.all) ],
        [ lambda { ApiClient::Info.fee_types },               parse(FeeType.all) ],
        [ lambda { ApiClient::Info.expense_types },           parse(ExpenseType.all) ]
      ])
    end
  end

  class ApiCreateExpectations < ExpectationCollection
    def self.default
      new([
        [ fees, /\w{8}-\w{4}-\w{4}-\w{4}-\w{12}/ ]
      ])
    end

    private

    def self.fees
      lambda { 
        ApiClient::Create.fees({
          claim_id:    Claim.first.uuid,
          fee_type_id: FeeType.first.id,
          quantity:    1,
          amount:      1,
        })
        .fetch('id', nil) 
      }
    end
  end

  class ApiValidateExpectations < ExpectationCollection
    def self.default
      new([
        [ fees, { 'valid' => true } ]
      ])
    end

    private

    def self.fees
      lambda { 
        ApiClient::Validate.fees({
          claim_id:    Claim.first.uuid,
          fee_type_id: FeeType.first.id,
          quantity:    1,
          amount:      1,
        })
      }
    end
  end
end
