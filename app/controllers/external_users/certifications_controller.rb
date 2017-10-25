class ExternalUsers::CertificationsController < ExternalUsers::ApplicationController
  before_action :set_claim, only: %i[new create update]
  before_action :redirect_already_certified, only: %i[new create]

  def new
    redirect_to external_users_claim_path(@claim), alert: 'Cannot certify a claim in submitted state' if @claim.submitted?

    @claim.force_validation = true
    if @claim.valid?
      build_certification
      track_visit({
                    url: 'external_user/%{type}/claim/%{action}/certification',
                    title: '%{action_t} %{type} claim certification'
                  }, claim_tracking_substitutions)
    else
      redirect_to edit_polymorphic_path(@claim), alert: 'Claim is not in a state to be submitted'
    end
  end

  def create
    @claim.build_certification(certification_params)
    if @claim.certification.save && claim_updater.submit
      begin
        MessageQueue::AwsClient.new(MessageQueue::MessageTemplate.claim_created(@claim.type, @claim.uuid), Settings.aws.queue).send_message!
        Rails.logger.info "Successfully sent message about submission of claim##{@claim.id}(#{@claim.uuid})"
      rescue StandardError => err
        Rails.logger.warn "Error: '#{err.message}' while sending message about submission of claim##{@claim.id}(#{@claim.uuid})"
      end
      redirect_to confirmation_external_users_claim_path(@claim)
    else
      @certification = @claim.certification
      render action: :new
    end
  end

  def update
    redirect_to external_users_claim_path(@claim), alert: 'Cannot certify a claim in submitted state'
  end

  private

  def redirect_already_certified
    redirect_to external_users_claim_path(@claim), alert: 'Cannot certify a claim in submitted state' if @claim.submitted?
  end

  def build_certification
    @certification = Certification.new(claim: @claim)
    @certification.certified_by = current_user.name
    @certification.certification_date = Date.today
  end

  def certification_params
    params.require(:certification).permit(
      :certification_type_id,
      :certified_by,
      :certification_date_dd,
      :certification_date_mm,
      :certification_date_yyyy
    )
  end

  def set_claim
    @claim = Claim::BaseClaim.active.find(params[:claim_id])
  end

  def claim_tracking_substitutions
    { type: @claim.pretty_type, action: @claim.edition_state, action_t: @claim.edition_state.titleize }
  end
end
