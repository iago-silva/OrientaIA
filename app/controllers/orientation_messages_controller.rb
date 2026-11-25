class OrientationMessagesController < ApplicationController
  def create
    orientation = current_student ? current_student.orientation : current_professor.orientations.find(params[:orientation_id])
    raise ActiveRecord::RecordNotFound unless orientation
    message = orientation.orientation_messages.new(content: params[:content], author_name: current_user.name, author_role: current_student ? "student" : "professor")
    target = current_student ? student_meetings_path : professor_meetings_path(orientation: orientation.id)
    redirect_to target, message.save ? { notice: "Mensagem enviada à orientação." } : { alert: message.errors.full_messages.to_sentence }
  end
end
