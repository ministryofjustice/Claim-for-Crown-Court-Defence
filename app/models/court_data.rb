class CourtData
  include ActiveModel::Model

  attr_reader :claim_id

  def initialize(**kwargs)
    @claim_id = kwargs[:claim_id]
  end

  def case_number
    @case_number ||= {
      claim: claim.case_number,
      hmcts: prosecution_case&.case_number
    }
  end

  def status = @status ||= { hmcts: prosecution_case&.status }

  def defendants
    @defendants ||= merge_defendants(*(claim_defendants + hmcts_defendants))
  end

  private

  def claim = @claim ||= Claim::BaseClaim.find(@claim_id)

  def prosecution_case
    @prosecution_case ||= prosecution_case_by_case_number || prosecution_case_by_defendants
  end

  def prosecution_case_by_case_number = LAA::Cda::ProsecutionCase.search(prosecution_case_reference: claim.case_number).first

  def prosecution_case_by_defendants
    claim.defendants.each do |defendant|
      prosecution_case = all_prosecution_case_by_defendant(defendant)
      return prosecution_case if prosecution_case
    end
    nil
  end

  def all_prosecution_case_by_defendant(defendant)
    representation_orders = defendant.representation_orders.map(&:maat_reference)
    LAA::Cda::ProsecutionCase.search(name: defendant.name, date_of_birth: defendant.date_of_birth)
                             .find do |prosecution_case|
      (prosecution_case.defendants.map { |d| d.representation_order&.reference } & representation_orders).any?
    end
  end

  def claim_defendants
    claim.defendants.map do |defendant|
      {
        maat_reference: defendant.earliest_representation_order.maat_reference,
        hmcts: nil,
        claim: {
          name: defendant.name,
          representation_order_date: defendant.earliest_representation_order.representation_order_date
        }
      }
    end
  end

  def hmcts_defendants
    return [] if prosecution_case.nil?

    prosecution_case.defendants.map do |defendant|
      {
        maat_reference: defendant&.representation_order&.reference || 'No representation order recorded',
        hmcts: {
          id: defendant.id,
          name: defendant.name,
          start: defendant&.representation_order&.start,
          end: defendant&.representation_order&.end,
          contract_number: defendant&.representation_order&.contract_number
        },
        claim: nil
      }
    end
  end

  def merge_defendants(*defendants)
    defendants.group_by do |defendant|
      defendant[:maat_reference]
    end.each_with_object([]) do |(maat_reference, versions), merged_defendants|
      if maat_reference == 'No representation order recorded'
        merged_defendants.append(*versions)
      else
        merged_defendants << versions.each_with_object({ maat_reference:, hmcts: nil,
                                                         claim: nil }) do |defendant, defendant_out|
          defendant_out[:hmcts] ||= defendant[:hmcts]
          defendant_out[:claim] ||= defendant[:claim]
        end
      end
    end
  end
end
