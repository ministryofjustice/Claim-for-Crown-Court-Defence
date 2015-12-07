class MessagesController < ApplicationController
  respond_to :html

  def index
    raise 'Must specifiy claim id' if params[:claim_id].blank?

    @claim = Claim.find(params[:claim_id])
    @messages = Message.for(@claim).most_recent_first
    @messages = @messages.where('created_at > ?', params[:after]) if params[:after].present?
    @message = @claim.messages.build

    respond_to do |format|
      format.js
    end
  end

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
