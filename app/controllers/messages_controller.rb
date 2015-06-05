class MessagesController < ApplicationController
  respond_to :html

  def create
    @message = Message.new(message_params.merge(sender_id: current_user.id))

    if @message.save!
      notification = { notice: 'Message successfully sent' }
    else
      notification = { alert: 'Message not sent: ' + @message.errors.full_messages.join(', ') }
    end

    redirect_to :back, notification
  end

  private

  def message_params
    params.require(:message).permit(
      :sender_id,
      :claim_id,
      :subject,
      :body
    )
  end
end
