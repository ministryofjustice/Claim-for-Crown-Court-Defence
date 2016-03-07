# == Schema Information
#
# Table name: messages
#
#  id                      :integer          not null, primary key
#  body                    :text
#  claim_id                :integer
#  sender_id               :integer
#  created_at              :datetime
#  updated_at              :datetime
#  attachment_file_name    :string
#  attachment_content_type :string
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#

class MessagesController < ApplicationController
  respond_to :html

  def create
    @message = Message.new(message_params.merge(sender_id: current_user.id))

    if @message.save
      set_refresh_required
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

  def set_refresh_required
    @refresh = Settings.claim_actions.include?(message_params[:claim_action])
  end

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
