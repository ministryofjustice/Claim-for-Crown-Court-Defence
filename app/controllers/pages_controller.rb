class PagesController < ApplicationController

  skip_load_and_authorize_resource
  before_action :suppress_hotline_link

  def tandcs; end

  def contact_us; end

  def api_landing; end

  def api_release_notes; end

  def servicedown; end

  private
  def suppress_hotline_link
    @suppress_contact_us_message = true
  end
end
