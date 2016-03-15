class ExternalUsers::Advocates::ClaimsController < ExternalUsers::ClaimsController

  skip_load_and_authorize_resource

  def new
    @claim = Claim::AdvocateClaim.new
    load_offences_and_case_types
    build_nested_resources
  end

  # def create
  #   params[:claim_type]
  #   @claim = Claim::AdvocateClaim.new(params_with_advocate_and_creator)
  #   if submitting_to_laa?
  #     create_and_submit
  #   else
  #     create_draft
  #   end
  # end

end
