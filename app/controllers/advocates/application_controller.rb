class Advocates::ApplicationController < ApplicationController
  before_action :authenticate_advocate!

  private

  def authenticate_advocate!
    unless user_signed_in? && current_user.persona.is_a?(Advocate)
      redirect_to root_url, alert: 'Must be signed in as an advocate'
    end
  end
end
