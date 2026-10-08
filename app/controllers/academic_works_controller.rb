class AcademicWorksController < ApplicationController
  before_action :require_student!

  def index
    @works = current_student.academic_works.includes(:work_versions, :review_comments).order(updated_at: :desc)
    @selected_work = @works.first
    @new_version = WorkVersion.new
  end

  def show
    @work = current_student.academic_works.includes(:work_versions, :review_comments).find(params[:id])
    @new_version = WorkVersion.new
    @reply = ReviewComment.new
    @version = @work.work_versions.find_by(version_number: params[:version].to_i) if params[:version].present?
    @version ||= @work.latest_version
  end
end
