class Advocates::Admin::AdvocatesController < Advocates::Admin::ApplicationController
  before_action :set_advocate, only: [:show, :edit, :update, :destroy]

  def index
    @advocates = current_user.persona.chamber.advocates
  end

  def show; end

  def edit; end

  def new
    @advocate = Advocate.new
    @advocate.build_user
  end

  def create
    @advocate = Advocate.new(advocate_params.merge(chamber_id: current_user.persona.chamber.id))

    if @advocate.save
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
      user_attributes: [:email, :password, :password_confirmation, :first_name, :last_name]
    )
  end
end
