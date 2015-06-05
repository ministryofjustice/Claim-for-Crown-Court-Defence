class UserMessageStatusesController < ApplicationController
  before_action :set_user_message_status, only: [:update]

  def index
    @user_message_statuses = UserMessageStatus.for(current_user).not_marked_as_read
  end

  def update
    @user_message_status.update(read: true)
  end

  private

  def set_user_message_status
    @user_message_status = UserMessageStatus.find(params[:id])
    @message = @user_message_status.message
  end
end
