class CourtData
  attr_reader :claim_id, :matching_method

  def initialize(**kwargs)
    @claim_id = kwargs[:claim_id]
    @matching_method = nil
  end

  def case_number
    @case_number ||= {
      claim: claim.case_number,
      hmcts: prosecution_case&.case_number
    }
  end

  def status = @status ||= { hmcts: prosecution_case&.status }

  def defendants
    @defendants ||= claim_defendants.map do |cd|
      CourtData::Defendant.new(claim: cd, hmcts: hmcts_defendants.find { |hd| hd == cd })
    end + hmcts_defendants.reject { |hd| claim_defendants.include?(hd) }
                          .map { |hd| CourtData::Defendant.new(hmcts: hd) }
  end

  private

  def claim = @claim ||= Claim::BaseClaim.find(@claim_id)

  def prosecution_case
    @prosecution_case ||= prosecution_case_by_case_number || prosecution_case_by_defendants
  end

  def prosecution_case_by_case_number
    LAA::Cda::ProsecutionCase.search(prosecution_case_reference: claim.case_number).first.tap do |response|
      @matching_method = 'URN' if response
    end
  end

  def prosecution_case_by_defendants
    claim.defendants.each do |defendant|
      prosecution_case = all_prosecution_case_by_defendant(defendant)
      if prosecution_case
        @matching_method = "'#{defendant.name}' and '#{defendant.date_of_birth}'"
        return prosecution_case
      end
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
    @claim_defendants ||= claim.defendants.map { |defendant| CourtData::Defendant::Claim.new(defendant:) }
  end

  def hmcts_defendants
    return [] if prosecution_case.nil?

    @hmcts_defendants ||= prosecution_case.defendants.map { |defendant| CourtData::Defendant::Hmcts.new(defendant:) }
  end
end
