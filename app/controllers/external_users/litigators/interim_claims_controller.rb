class ExternalUsers::Litigators::InterimClaimsController < ExternalUsers::ClaimsController
  skip_load_and_authorize_resource

  resource_klass Claim::InterimClaim

  def new
    super
    @claim.main_hearing_date ||= Time.zone.today
  end

  private

  def build_nested_resources
    @claim.build_interim_fee if @claim.interim_fee.nil?

    %i[disbursements expenses].each do |association|
      build_nested_resource(@claim, association)
    end

    super
  end
end
