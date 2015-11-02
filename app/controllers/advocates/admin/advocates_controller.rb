class Advocates::Admin::AdvocatesController < Advocates::Admin::ApplicationController
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
    new_advocate_params = advocate_params
    temporary_password = SecureRandom.uuid
    new_advocate_params['user_attributes']['password'] = temporary_password
    new_advocate_params['user_attributes']['password_confirmation'] = temporary_password

    @advocate = Advocate.new(new_advocate_params.merge(chamber_id: current_user.persona.chamber.id))

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
    password_params = advocate_params.slice(:user_attributes)
    password_params[:user_attributes].delete(:email)
    password_params[:user_attributes].delete(:first_name)
    password_params[:user_attributes].delete(:last_name)

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
      user_attributes: [:id, :email, :password, :password_confirmation, :current_password, :first_name, :last_name]
    )
  end

end
