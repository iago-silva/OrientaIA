class DashboardController < ApplicationController
  def index
    if current_student
      @student = current_student
      @orientation = @student.orientation
      @works = @student.academic_works.includes(:work_versions, :review_comments).order(updated_at: :desc)
      @next_tasks = @orientation ? @orientation.tasks.where(status: %w[pending in_progress]).order(:due_on).limit(4) : []
      @upcoming_meeting = @orientation&.next_meeting_at
      @recommendations = @student.opportunity_recommendations.where(status: %w[recommended saved]).order(relevance: :desc).limit(2)
      @recent_meetings = @orientation ? @orientation.meetings.order(held_at: :desc).limit(2) : []
      render "student_dashboard"
      return
    end

    @students = current_professor.students.where(active: true).order(:name)
    @orientations = current_professor.orientations.includes(:student).where(status: "active")
    @upcoming = @orientations.where(next_meeting_at: Time.current..).order(:next_meeting_at).limit(5)
    @pending_tasks = Task.joins(:orientation).where(orientations: { professor_id: current_professor.id }, status: %w[pending in_progress])
      .includes(orientation: :student).order(:due_on).limit(5)
    @open_task_count = Task.joins(:orientation).where(orientations: { professor_id: current_professor.id }, status: %w[pending in_progress]).count
    @completed_count = @orientations.joins(:tasks).where(tasks: { status: "completed" }).distinct.count
    @recent_meetings = Meeting.joins(orientation: :professor).where(orientations: { professor_id: current_professor.id })
      .includes(orientation: :student).order(held_at: :desc).limit(3)
  end
end
