class StudentMeetingsController < ApplicationController
  before_action :require_student!

  def index
    @orientation = current_student.orientation
    @meetings = @orientation ? @orientation.meetings.order(held_at: :desc) : Meeting.none
    @meetings = @meetings.where("title LIKE ? OR summary LIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
    @meeting = Meeting.new(held_at: Time.current)
    @selected_meeting = @meetings.find_by(id: params[:meeting]) || @meetings.first
    @student_work = current_student.academic_works.first
  end

  def create
    orientation = current_student.orientation
    return redirect_to root_path, alert: "Nenhum acompanhamento foi vinculado a este perfil." unless orientation

    meeting = orientation.meetings.new(meeting_params.merge(source: "web"))
    if meeting.save
      meeting.audio_file.attach(params[:meeting][:audio_file]) if params.dig(:meeting, :audio_file).present?
      redirect_to student_meetings_path, notice: "Registro da reunião salvo."
    else
      redirect_to student_meetings_path, alert: meeting.errors.full_messages.to_sentence
    end
  end

  private

  def meeting_params
    params.require(:meeting).permit(:held_at, :title, :transcript, :summary, :next_steps)
  end
end
