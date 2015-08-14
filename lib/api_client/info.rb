module ApiClient
  module Info
    extend ApiClient
    extend self

    def case_types
      fetch('case_types')
    end

    def courts
      fetch('courts')
    end

    def advocate_categories
      fetch('advocate_categories')
    end

    def prosecuting_authorities
      fetch('prosecuting_authorities')
    end

    def trial_cracked_at_thirds
      fetch('trial_cracked_at_thirds')
    end

    def granting_body_types
      fetch('granting_body_types')
    end

    def offence_classes
      fetch('offence_classes')
    end

    def offences
      fetch('offences')
    end

    def fee_categories
      fetch('fee_categories')
    end

    def fee_types
      fetch('fee_types')
    end

    def expense_types
      fetch('expense_types')
    end
  end
end