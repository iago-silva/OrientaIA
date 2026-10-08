class AbntChecksController < ApplicationController
  before_action :require_student!

  def update
    check = AbntCheck.joins(:academic_work).where(academic_works: { student_id: current_student.id }).find(params[:id])
    if check.update(status: "verified", checked_at: Time.current)
      redirect_to abnt_analysis_path, notice: "Item marcado para conferência humana."
    else
      redirect_to abnt_analysis_path, alert: check.errors.full_messages.to_sentence
    end
  end
end
