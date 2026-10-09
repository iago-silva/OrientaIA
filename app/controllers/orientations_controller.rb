class OrientationsController < ApplicationController
  before_action :require_professor!
  before_action :set_orientation, only: %i[show update]

  def index
    @orientations = current_professor.orientations.includes(:student).order(:status, "students.name")
  end

  def show
    @meetings = @orientation.meetings.to_a.select(&:persisted?)
    @feedbacks = @orientation.feedbacks.to_a.select(&:persisted?)
    @tasks = @orientation.tasks.to_a.select(&:persisted?)
    @meeting = @orientation.meetings.new(held_at: Time.current)
    @task = @orientation.tasks.new
    @feedback = @orientation.feedbacks.new(author_name: current_professor.name)
  end

  def update
    if @orientation.update(orientation_params)
      redirect_to orientation_path(@orientation), notice: "Agenda da orientação atualizada."
    else
      redirect_to orientation_path(@orientation), alert: @orientation.errors.full_messages.to_sentence
    end
  end

  private

  def set_orientation
    @orientation = current_professor.orientations.includes(:student, :meetings, :tasks, :feedbacks).find(params[:id])
  end

  def orientation_params
    params.require(:orientation).permit(:next_meeting_at, :notes)
  end
end
