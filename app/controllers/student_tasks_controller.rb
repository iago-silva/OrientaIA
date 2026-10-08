class StudentTasksController < ApplicationController
  before_action :require_student!

  def update
    task = current_student.orientation&.tasks&.find_by(id: params[:id])
    return redirect_to student_agenda_path, alert: "Tarefa não encontrada." unless task

    status = params.dig(:task, :status)
    return redirect_to student_agenda_path, alert: "Status inválido." unless Task::STATUSES.include?(status)

    task.update!(status: status, completed_at: status == "completed" ? Time.current : nil)
    redirect_to student_agenda_path, notice: "Tarefa atualizada."
  end
end
