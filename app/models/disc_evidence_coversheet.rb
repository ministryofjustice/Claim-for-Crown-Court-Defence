class DiscEvidenceCoversheet
  include ActiveModel::Model
  include GovUk::DateAccessor

  attr_reader :claim, :params
  attr_writer :fee_scheme,
              :case_number,
              :court_name,
              :defendant_name,
              :maat_reference,
              :provider_account_no,
              :provider_address,
              :data_storage_type

  attr_reader :data_storage_type

  gov_uk_date_accessor :current_date, :claim_submitted_at

  def initialize(claim, params = {})
    @claim = claim
    @params = params
    super(params)
  end

  def current_date
    date_from_parts(:current_date) || Date.current
  end

  def fee_scheme
    @fee_scheme || @claim.fee_scheme.name.upcase
  end

  def agfs?
    fee_scheme.eql?('AGFS')
  end

  def lgfs?
    fee_scheme.eql?('LGFS')
  end

  def case_number
    @case_number || @claim.case_number
  end

  def court_name
    @court_name || @claim.court.name
  end

  def claim_submitted_at
    date_from_parts(:claim_submitted_at) || Date.current
  end

  def defendant_name
    @defendant_name || @claim&.defendants&.first&.name
  end

  def maat_reference
    @maat_reference || @claim.earliest_representation_order.maat_reference
  end

  def provider_account_no
    @provider_account_no || @claim.supplier_number
  end

  def provider_address
    @provider_address&.strip
  end

  private

  def date_from_parts(field)
    Date.new(params["#{field}_yyyy"].to_i, params["#{field}_mm"].to_i, params["#{field}_dd"].to_i)
  rescue ArgumentError
    nil
  end
end
