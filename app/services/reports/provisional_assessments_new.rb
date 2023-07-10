module Reports
  class ProvisionalAssessmentsNew
    COLUMNS = %w[
      supplier_name
      total
      assessed
      disallowed
      bill_type
      case_type
      earliest_representation_order_date
      case_worker
      maat_number
    ].freeze
    INCLUDES = [
      :case_type,
      :determinations,
      :case_workers,
      {
        external_user: :provider,
        defendants: :representation_orders
      }
    ].freeze

    def self.call = new.call

    def call
      Claim::BaseClaim.includes(INCLUDES)
                      .where(state: %w[authorised part_authorised])
                      .map { |claim| format_row(claim) }.to_a
    end

    private

    def format_row(claim)
      total = claim.total_including_vat
      assessed = claim.amount_assessed
      [
        claim.provider.name, total, assessed, total - assessed,
        'TBD - Bill type',
        claim.case_type.name,
        claim.earliest_representation_order_date,
        claim.case_workers.last.name,
        claim.defendants.last.representation_orders.last.maat_reference
      ]
    end
  end
end
