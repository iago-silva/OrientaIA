class TasksController < ApplicationController
  before_action :require_professor!
  def create
    @orientation = current_professor.orientations.find(params[:orientation_id])
    @task = @orientation.tasks.new(task_params.merge(source: "web"))
    if @task.save
      redirect_to orientation_path(@orientation), notice: "Tarefa criada."
    else
      redirect_to orientation_path(@orientation), alert: @task.errors.full_messages.to_sentence
    end
  end

  def update
    @orientation = current_professor.orientations.find(params[:orientation_id])
    @task = @orientation.tasks.find(params[:id])
    if @task.update(task_update_params)
      @task.update!(completed_at: Time.current) if @task.status == "completed" && @task.completed_at.blank?
      redirect_to orientation_path(@orientation), notice: "Tarefa atualizada."
    else
      redirect_to orientation_path(@orientation), alert: @task.errors.full_messages.to_sentence
    end
  end

  private

  def task_params
    params.require(:task).permit(:title, :description, :due_on)
  end

  def task_update_params
    params.require(:task).permit(:status)
  end
end
