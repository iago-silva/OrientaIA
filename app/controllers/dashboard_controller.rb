class DashboardController < ApplicationController
  def index
    if current_student
      @student = current_student
      @orientation = @student.orientation
      @works = @student.academic_works.includes(:work_versions).order(:id)
      @comments = ReviewComment.joins(:academic_work).where(academic_works: { student_id: @student.id }).where.not(published_at: nil)
      @tasks = @orientation ? @orientation.tasks.where.not(status: "completed").limit(3) : Task.none
      render :student_dashboard
    else
      @orientations = current_professor.orientations.includes(:student)
      @orientation = @orientations.first
      @records = ReviewRecord.joins(:orientation).where(orientations: { professor_id: current_professor.id }).pending.order(created_at: :desc)
      @upcoming = @orientations.where.not(next_meeting_at: nil).order(:next_meeting_at).first
    end
  end
end
