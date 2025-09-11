# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  persona_id             :integer
#  persona_type           :string
#  created_at             :datetime
#  updated_at             :datetime
#  first_name             :string
#  last_name              :string
#  failed_attempts        :integer          default(0), not null
#  locked_at              :datetime
#  unlock_token           :string
#  settings               :text
#  deleted_at             :datetime
#  api_key                :uuid
#

class UsersController < ApplicationController
  include PaginationHelpers

  def index
    @pagy, @users = pagy(User.order(created_at: :desc), page: current_page, limit: page_size)
  end

  def update_settings
    @settings = settings_params
    @result = current_user.save_settings!(@settings)
    respond_to :js
  end

  private

  def settings_params
    params.except(:id).permit(:api_promo_seen, :timed_retention_banner_seen, :hardship_claims_banner_seen,
                              :clair_contingency_banner_seen, :out_of_hours_banner_seen)
  end
end
