class ExternalUsers::Litigators::TransferClaimsController < ExternalUsers::ClaimsController
  skip_load_and_authorize_resource

  resource_klass Claim::TransferClaim

  private

  def build_nested_resources
    @claim.build_transfer_detail if @claim.transfer_detail.nil?
    @claim.build_transfer_fee    if @claim.transfer_fee.nil?

    %i[misc_fees disbursements expenses].each do |association|
      build_nested_resource(@claim, association)
    end

    super
  end
end
