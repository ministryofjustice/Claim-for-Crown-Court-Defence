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
  include ActiveStorage::SetCurrent

  respond_to :html

  def create
    @message = Message.new(message_params.merge(sender_id: current_user.id))
    attach_documents(@message)
    save_message(@message)
    respond_to do |format|
      format.js
      format.html { redirect_to redirect_to_url, @notification }
    end
  end

  def download_attachment
    raise 'No attachment present on this message' unless message.attachments.attached?

    attachment = message.attachments.find(params[:attachment_id])
    redirect_to attachment.blob.url(disposition: 'attachment'), allow_other_host: true
  end

  private

  def message
    @message ||= Message.find(params[:id])
  end

  def redirect_to_url
    method = "#{current_user.persona.class.to_s.pluralize.underscore}_claim_path"
    __send__(method, @message.claim, messages: true) + '#claim-accordion'
  end

  def refresh_required?
    Settings.claim_actions.include?(message_params[:claim_action])
  end

  def message_params
    params.require(:message).permit(
      :sender_id,
      :claim_id,
      :attachments,
      :body,
      :claim_action,
      :written_reasons_submitted
    )
  end

  def attach_documents(message)
    documents = Document.where(id: params[:message][:document_ids], creator_id: current_user.id)
    documents.each do |doc|
      message.attachments.attach(doc.document.blob)
    end
  end

  def save_message(message)
    @notification = if message.save
                      { notice: 'Message successfully sent' }
                    else
                      { alert: 'Message not sent: ' + message.errors.full_messages.join(', ') }
                    end
  end
end
