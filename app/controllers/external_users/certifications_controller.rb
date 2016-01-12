class ExternalUsers::CertificationsController < ExternalUsers::ApplicationController
  before_action :set_claim, only: [:new, :create]

  def new
    redirect_to external_users_claim_path(@claim), alert: 'Cannot certify a claim in submitted state' if @claim.submitted?

    @claim.force_validation = true
    if @claim.valid?
      build_certification
    else
      redirect_to edit_external_users_claim_path(@claim), alert: 'Claim is not in a state to be submitted'
    end
  end

  def create
    @claim.build_certification(certification_params)
    if @claim.certification.save && @claim.submit
      send_ga('event', 'submit', 'certified', certification_params.select{|k,v| v == '1'}.keys.join(', '))
      redirect_to confirmation_external_users_claim_path(@claim), notice: 'Claim submitted to LAA'
    else
      @certification = @claim.certification
      render action: :new
    end
  end

  private

  def build_certification
    @certification = Certification.new(claim: @claim)
    @certification.certified_by = current_user.name
    @certification.certification_date = Date.today
  end

  def certification_params
    params.require(:certification).permit(
      :main_hearing,
      :notified_court,
      :attended_pcmh,
      :attended_first_hearing,
      :previous_advocate_notified_court,
      :fixed_fee_case,
      :certified_by,
      :certification_date_dd,
      :certification_date_mm,
      :certification_date_yyyy
    )
  end

  def set_claim
    @claim = Claim.find(params[:claim_id])
  end
end
