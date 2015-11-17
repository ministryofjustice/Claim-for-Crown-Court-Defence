class MessagesController < ApplicationController
  respond_to :html

  def create
    @message = Message.new(message_params.merge(sender_id: current_user.id))

    if @message.save
      @notification = { notice: 'Message successfully sent' }
    else
      @notification = { alert: 'Message not sent: ' + @message.errors.full_messages.join(', ') }
    end

    respond_to do |format|
      format.js
      format.html { redirect_to :back, @notification }
    end
  end

  def download_attachment
    @message = Message.find(params[:id])

    raise 'No attachment present on this message' if @message.attachment.blank?

    send_file Paperclip.io_adapters.for(@message.attachment).path, {
        type:        @message.attachment_content_type,
        filename:    @message.attachment_file_name,
        x_sendfile:  true
      }
  end

  def show_control
    @claim = Claim.find(params[:id])
    @message = @claim.messages.build
    @message.claim_action = params[:message][:claim_action]

    raise 'No claim identified' if @claim.blank?

    respond_to do |format|
      format.js
    end

  end

  private

  def message_params
    params.require(:message).permit(
      :sender_id,
      :claim_id,
      :attachment,
      :body,
      :claim_action,
      :written_reasons_submitted
    )
  end
end
