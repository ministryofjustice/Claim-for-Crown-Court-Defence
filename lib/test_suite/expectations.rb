module TestSuite
  class Expectations
    attr_reader :all

    def self.default
      raise NotImplementedError, '#default factory method must be implemented by subclasses'
    end

    protected

    def initialize(expectations)
      @all = expectations
    end

    def self.parse(activerecord_collection)
      ApiClient::PARSER.parse(MultiJson.dump(activerecord_collection))
    end
  end

  class ApiInfoExpectations < Expectations
    def self.default
      new({
        case_types:              Settings.case_types,
        courts:                  parse(Court.all),
        advocate_categories:     Settings.advocate_categories,
        prosecuting_authorities: Settings.prosecuting_authorities,
        trial_cracked_at_thirds: Settings.trial_cracked_at_third,
        granting_body_types:     Settings.court_types,
        offence_classes:         parse(OffenceClass.all),
        offences:                parse(Offence.all),
        fee_categories:          parse(FeeCategory.all),
        fee_types:               parse(FeeType.all),
        expense_types:           parse(ExpenseType.all)
      })
    end
  end

  class ApiCreateExpectations < Expectations
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

  class ApiValidateExpectations < Expectations
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
