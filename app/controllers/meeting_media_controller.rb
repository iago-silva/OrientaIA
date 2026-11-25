class MeetingMediaController < ApplicationController
  def show
    scope = current_student ? Meeting.joins(:orientation).where(orientations: { student_id: current_student.id }) : Meeting.joins(:orientation).where(orientations: { professor_id: current_professor.id })
    meeting = scope.find(params[:id])
    raise ActiveRecord::RecordNotFound unless meeting.audio_file.attached?
    if current_student && meeting.shared_content["transcript"].blank?
      raise ActiveRecord::RecordNotFound
    end
    response.headers["Cache-Control"] = "no-store"
    send_data meeting.audio_file.download, filename: meeting.audio_file.filename.to_s, type: meeting.audio_file.content_type, disposition: "inline"
  end
end
