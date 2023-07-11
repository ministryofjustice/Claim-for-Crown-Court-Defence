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

    def self.call(...) = new(...).call

    def call
      Claim::BaseClaim.includes(INCLUDES)
                      .where(state: %w[authorised part_authorised])
                      .map { |claim| format_row(claim) }.to_a
    end

    private

    def format_row(claim) = summary_fields(claim) + extended_fields(claim)

    def summary_fields(claim)
      [
        claim.provider.name,
        claim.total_including_vat,
        claim.amount_assessed,
        claim.total_including_vat - claim.amount_assessed
      ]
    end

    def extended_fields(claim)
      [
        claim.type.gsub('Claim::', ''),
        claim.case_type.name,
        claim.earliest_representation_order_date,
        claim.case_workers.last.name,
        claim.defendants.last.representation_orders.last.maat_reference
      ]
    end
  end
end
