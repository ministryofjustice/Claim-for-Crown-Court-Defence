class PagesController < ApplicationController
  skip_load_and_authorize_resource
  before_action :suppress_hotline_link

  def tandcs; end

  def contact_us; end

  def api_landing; end

  def api_release_notes; end

  def servicedown
    respond_to do |format|
      format.html { render :servicedown }
      format.json { render json: [{ error: 'Temporarily unavailable' }], status: 503 }
    end
  end

  def timed_retention; end
end
