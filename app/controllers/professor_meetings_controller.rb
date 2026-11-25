class ProfessorMeetingsController < ApplicationController
  before_action :require_professor!

  def index
    @orientations = current_professor.orientations.includes(:student)
    @orientation = @orientations.find_by(id: params[:orientation]) || @orientations.first
    @meetings = @orientation ? @orientation.meetings.includes(:review_record) : Meeting.none
    @meetings = @meetings.where("meetings.title LIKE ?", "%#{params[:q]}%") if params[:q].present?
    @selected_meeting = @meetings.find_by(id: params[:meeting]) || @meetings.first
  end
end
