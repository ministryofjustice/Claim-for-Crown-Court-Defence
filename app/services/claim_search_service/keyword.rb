class ClaimSearchService
  class Keyword < Base
    SPACE = Arel::Nodes.build_quoted(' ').freeze

    def initialize(search, term:, admin:)
      super

      @term = "%#{term}%"
      @admin = admin
    end

    def run
      @search.run.merge(or_chain)
    end

    def self.decorate(search, term: nil, user: nil, **_params)
      return search if term.blank?

      new(search, term: term, admin: user&.admin?)
    end

    private

    def or_chain
      fields.inject(stub.none) do |partial_search, field|
        partial_search.or(stub.where(field.matches(@term)))
      end
    end

    def fields
      @fields ||= begin
        fields = [
          Claim::BaseClaim.arel_table[:case_number],
          full_name_for(Defendant),
          RepresentationOrder.arel_table[:maat_reference]
        ]
        @admin ? fields + [full_name_for(User), User.arel_table[:email]] : fields
      end
    end

    def full_name_for(model)
      Arel::Nodes::NamedFunction.new('concat', [model.arel_table[:first_name], SPACE, model.arel_table[:last_name]])
    end

    def stub
      @stub ||= Claim::BaseClaim.joins(joins)
    end

    def joins
      return { defendants: :representation_orders, case_workers: :user } if @admin

      { defendants: :representation_orders }
    end
  end
end
