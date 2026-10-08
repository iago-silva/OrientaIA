class AbntAnalysesController < ApplicationController
  before_action :require_student!

  def show
    @work = current_student.academic_works.includes(:abnt_checks, :work_versions).find_by(category: "Capítulo 2") || current_student.academic_works.first
    @checks = @work ? @work.abnt_checks : AbntCheck.none
    @verified_count = @checks.where(status: "verified").count
    @suggestion_count = @checks.where(status: "suggestion").count
    @manual_count = @checks.where(status: "manual_review").count
    @selected_check = @checks.find_by(id: params[:check]) || @checks.where(status: "suggestion").first
  end
end
