class SessionsController < ApplicationController
  skip_before_action :require_user!, only: %i[new create]

  def new
    redirect_to root_path if current_user
  end

  def create
    professor = Professor.find_by(email: params[:email].to_s.strip.downcase)
    if professor&.authenticate(params[:password])
      reset_session
      session[:professor_id] = professor.id
      redirect_to root_path, notice: "Bem-vinda, #{professor.name.split.first}!"
    elsif (student = Student.find_by(email: params[:email].to_s.strip.downcase))&.authenticate(params[:password])
      reset_session
      session[:student_id] = student.id
      redirect_to root_path, notice: "Bem-vinda, #{student.name.split.first}!"
    else
      flash.now[:alert] = "E-mail ou senha inválidos."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Você saiu do portal."
  end
end
