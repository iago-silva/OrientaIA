class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_professor, :current_student, :current_user

  before_action :require_user!

  private

  def current_professor
    @current_professor ||= Professor.find_by(id: session[:professor_id]) if session[:professor_id]
  end

  def current_student
    @current_student ||= Student.find_by(id: session[:student_id]) if session[:student_id]
  end

  def current_user
    current_student || current_professor
  end

  def require_user!
    return if current_user

    redirect_to login_path, alert: "Entre na sua conta para continuar."
  end

  def require_professor!
    return if current_professor

    redirect_to root_path, alert: "Esta área está disponível para a equipe de orientação."
  end

  def require_student!
    return if current_student

    redirect_to root_path, alert: "Entre como estudante para acessar este espaço."
  end
end
