class RegistrationsController < ApplicationController
  skip_before_action :require_user!, only: %i[new create]

  def new
    redirect_to root_path if current_user
    @professor = Professor.new
  end

  def create
    @professor = Professor.new(professor_params)
    if @professor.save
      session[:professor_id] = @professor.id
      redirect_to root_path, notice: "Conta criada. Boas-vindas ao OrientaAI!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def professor_params
    params.require(:professor).permit(:name, :email, :institution, :password, :password_confirmation)
  end
end
