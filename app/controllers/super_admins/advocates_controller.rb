class SuperAdmins::AdvocatesController < ApplicationController
  
  before_action :set_chamber,   only: [:show, :index, :edit, :update, :new, :create]
  before_action :set_advocate,  only: [:show, :edit]

  def show; end

  def index
    @advocates = Advocate.where(chamber: @chamber)
  end

  def new
    @advocate = Advocate.new(chamber: @chamber)
  end

  def create
    @advocate = Advocate.new(params_with_temporary_password.merge(chamber: @chamber))

    if @advocate.save
      @advocate.user.send_reset_password_instructions
      redirect_to super_admins_chamber_advocates_path(@chamber), notice: 'Advocate successfully created'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @advocate.update(advocate_params)
     redirect_to super_admins_advocate_path(@chamber,@advocate), notice: 'Advocate successfully updated'
    else
      render :edit
    end
  end

  private

  def advocate_params
    params.require(:advocate).permit(
     :role,
     :apply_vat,
     :supplier_number,
     user_attributes: [:id, :email, :email_confirmation, :password, :password_confirmation, :current_password, :first_name, :last_name]
    )
  end

  def set_advocate
    @advocate  = Advocate.find(params[:id])
  end

  def set_chamber
    @chamber = Chamber.find(params[:chamber_id])
  end

end
