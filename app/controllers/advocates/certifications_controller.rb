class Advocates::CertificationsController < Advocates::ApplicationController
      
  def new
    @claim = Claim.find(params[:claim_id])
    if @claim.submitted?
      flash.alert = 'Cannot certify a claim in submitted state' 
      redirect_to advocates_claim_path(@claim)
    else
      @certification = Certification.new(claim: @claim)
      @certification.certified_by = current_user.name
      @certification.certification_date = Date.today
    end
  end


  def create
    @claim = Claim.find(params[:claim_id])
    @claim.build_certification(certification_params)

    if @claim.certification.save && @claim.submit
      @notification = { notice: 'Claim submitted to LAA' }
      redirect_to confirmation_advocates_claim_path(@claim)
    else
      @certification = @claim.certification
      render action: :new
    end
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
      :certification_date
    )
  end


end
