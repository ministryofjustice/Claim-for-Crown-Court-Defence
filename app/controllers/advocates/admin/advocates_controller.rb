class Advocates::Admin::AdvocatesController < Advocates::Admin::ApplicationController

  include PasswordHelpers

  before_action :set_advocate, only: [:show, :edit, :update, :destroy, :change_password, :update_password]

  def index
    @advocates = current_user.persona.provider.advocates.joins(:user)
    @advocates = @advocates.where("lower(users.first_name || ' ' || users.last_name) ILIKE :term", term: "%#{params[:search]}%") if params[:search].present?
    @advocates = @advocates.ordered_by_last_name
  end

  def show; end

  def edit; end

  def change_password; end

  def new
    @advocate = Advocate.new
    @advocate.build_user
  end

  def create
    @advocate = Advocate.new(params_with_temporary_password.merge(provider_id: current_user.persona.provider.id))

    if @advocate.save
      send_ga('event', 'advocate', 'created')
      @advocate.user.send_reset_password_instructions
      redirect_to advocates_admin_advocates_url, notice: 'Advocate successfully created'
    else
      render :new
    end
  end

  def update
    if @advocate.update(advocate_params)
      send_ga('event', 'advocate', 'updated', @advocate.id == @current_user.persona_id ? 'self' : 'other')
      redirect_to advocates_admin_advocates_url, notice: 'Advocate successfully updated'
    else
      render :edit
    end
  end

  # NOTE: update_password in PasswordHelper

  def destroy
    @advocate.destroy
    send_ga('event', 'advocate', 'deleted')
    redirect_to advocates_admin_advocates_url, notice: 'Advocate deleted'
  end

  private

  def set_advocate
    @advocate = Advocate.find(params[:id])
  end

  def advocate_params
    params.require(:advocate).permit(
     :role,
     :apply_vat,
     :supplier_number,
     user_attributes: [:id, :email, :email_confirmation, :password, :password_confirmation, :current_password, :first_name, :last_name]
    )
  end
end
