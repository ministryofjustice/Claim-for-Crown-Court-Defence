module MessageControlsDisplay
  extend ActiveSupport::Concern

  def show_message_controls
    @message = @claim.messages.build
    @message.claim_action = params[:claim_action]

    respond_to do |format|
      format.js { render template: 'shared/show_message_controls' }
    end
  end
end
