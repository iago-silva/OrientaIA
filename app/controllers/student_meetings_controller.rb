class StudentMeetingsController < ApplicationController
  before_action :require_student!

  def index
    @orientation = current_student.orientation
    @meetings = @orientation ? @orientation.meetings.includes(:review_record) : Meeting.none
    @meetings = @meetings.where("title LIKE ?", "%#{params[:q]}%") if params[:q].present?
    @selected_meeting = @meetings.find_by(id: params[:meeting]) || @meetings.first
    @messages = @orientation ? @orientation.orientation_messages.order(:created_at) : OrientationMessage.none
  end

  def create
    orientation = current_student.orientation
    raise ActiveRecord::RecordNotFound unless orientation
    meeting = orientation.meetings.new(params.require(:meeting).permit(:held_at, :title, :transcript, :summary, :next_steps, :audio_file).merge(source: "web"))
    redirect_to student_meetings_path, meeting.save ? { notice: "Reunião registrada e enviada para validação docente." } : { alert: meeting.errors.full_messages.to_sentence }
  end

  def export
    orientation = current_student.orientation
    raise ActiveRecord::RecordNotFound unless orientation
    meeting = orientation.meetings.find(params[:id])
    return redirect_to student_meetings_path(meeting: meeting.id), alert: "Exportação indisponível até a aprovação explícita da orientadora." unless meeting.review_record&.status == "published"
    text = [ "OrientaAI — #{meeting.title}", "Aprovado por #{meeting.review_record.published_by}", *meeting.shared_content.map { |key, value| "#{key.humanize}\n#{value}" } ].join("\n\n")
    send_data text, filename: "reuniao-#{meeting.id}.txt", type: "text/plain; charset=utf-8"
  end
end
