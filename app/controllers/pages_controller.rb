class PagesController < ApplicationController
  skip_load_and_authorize_resource
  before_action :suppress_hotline_link

  def tandcs; end

  def vendor_tandcs; end

  def contact_us; end

  def api_landing; end

  def api_release_notes; end

  def servicedown
    respond_to do |format|
      format.html { render :servicedown }
      format.json { render json: [{ error: 'Service temporarily unavailable' }], status: :service_unavailable }
      format.js { render json: [{ error: 'Service temporarily unavailable' }], status: :service_unavailable }
      format.all { render plain: 'error: Service temporarily unavailable', status: :service_unavailable }
    end
  end

  def timed_retention; end

  def hardship_claims; end

  def beta_enable
    session['beta_testing'] = 'enabled'
    redirect_back_or_to unauthenticated_root_path
  end

  def beta_disable
    session['beta_testing'] = 'disabled'
    redirect_back_or_to unauthenticated_root_path
  end
end
