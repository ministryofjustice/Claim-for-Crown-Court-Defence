class Advocates::Admin::AdvocatesController < Advocates::Admin::ApplicationController

  include PasswordHelpers

  before_action :set_advocate, only: [:show, :edit, :update, :destroy, :change_password, :update_password]

  def index
    @advocates = current_user.persona.chamber.advocates.ordered_by_last_name
  end

  def show; end

  def edit; end

  def change_password; end

  def new
    @advocate = Advocate.new
    @advocate.build_user
  end

  def create
    @advocate = Advocate.new(params_with_temporary_password.merge(chamber_id: current_user.persona.chamber.id))

    if @advocate.save
      @advocate.user.send_reset_password_instructions
      redirect_to advocates_admin_advocates_url, notice: 'Advocate successfully created'
    else
      render :new
    end
  end

  def update
    if @advocate.update(advocate_params)
      redirect_to advocates_admin_advocates_url, notice: 'Advocate successfully updated'
    else
      render :edit
    end
  end

  def update_password
    user = @advocate.user
    if user.update_with_password(password_params[:user_attributes])
      sign_in(user, bypass: true)
      redirect_to advocates_admin_advocate_path(@advocate), notice: 'Password successfully updated'
    else
      render :change_password
    end
  end

  def destroy
    @advocate.destroy
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
