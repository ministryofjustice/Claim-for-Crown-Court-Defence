# == Schema Information
#
# Table name: user_message_statuses
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  message_id :integer
#  read       :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

class UserMessageStatusesController < ApplicationController
  before_action :set_user_message_status, only: [:update]

  def index
    @user_message_statuses = UserMessageStatus.for(current_user).not_marked_as_read
  end

  def update
    @user_message_status.update(read: true)

    respond_to do |format|
      format.html { redirect_back(fallback_location: :root_path) }
      format.js
    end
  end

  private

  def set_user_message_status
    @user_message_status = UserMessageStatus.find(params[:id])
    @message = @user_message_status.message
  end
end
