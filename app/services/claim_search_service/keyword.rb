class ClaimSearchService
  class Keyword < Base
    STATUSES = %w[archived allocated current].freeze

    def initialize(search, term:)
      super

      @term = "%#{term}%"
    end

    def run
      @search.run.merge(or_chain)
    end

    def self.decorate(claim_search, status: nil, search: nil, **_params)
      return claim_search unless STATUSES.include?(status) && search.present?

      new(claim_search, term: search)
    end

    private

    def or_chain
      fields.inject(stub.none) do |partial_search, field|
        partial_search.or(stub.where(field.matches(@term)))
      end
    end

    def fields
      [
        Claim::BaseClaim.arel_table[:case_number],
        Defendant.arel_table[:first_name],
        Defendant.arel_table[:last_name],
        User.arel_table[:first_name],
        User.arel_table[:last_name],
        RepresentationOrder.arel_table[:maat_reference]
      ]
    end

    def stub
      @stub ||= Claim::BaseClaim.joins(
        defendants: :representation_orders,
        external_user: :user
      )
    end
  end
end
