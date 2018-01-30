class ExternalUsers::CertificationsController < ExternalUsers::ApplicationController
  before_action :set_claim, only: %i[new create update]
  before_action :redirect_already_certified, only: %i[new create]

  def new
    redirect_to external_users_claim_path(@claim), alert: t('shared.certification.alert') if @claim.submitted?

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
      notify_legacy_importers
      redirect_to confirmation_external_users_claim_path(@claim)
    else
      @certification = @claim.certification
      render action: :new
    end
  end

  def update
    redirect_to external_users_claim_path(@claim), alert: t('shared.certification.alert')
  end

  private

  def redirect_already_certified
    redirect_to external_users_claim_path(@claim), alert: t('shared.certification.alert') if @claim.submitted?
  end

  def notify_legacy_importers
    sqs_enqueue(queue: Settings.aws.submitted_queue) if @claim.agfs?
    publish_via_sns
    Rails.logger.info "Successfully sent #{log_suffix}"
  rescue StandardError => err
    Rails.logger.warn "Error: '#{err.message}' while sending #{log_suffix}"
  end

  def publish_via_sns
    NotificationQueue::AwsClient.new.send!(@claim)
  end

  def sqs_enqueue(queue:)
    message = MessageQueue::MessageTemplate.claim_created(@claim.type, @claim.uuid)
    MessageQueue::AwsClient.new(queue).send!(message)
  end

  def log_suffix
    "message about submission of claim##{@claim.id}(#{@claim.uuid})"
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
