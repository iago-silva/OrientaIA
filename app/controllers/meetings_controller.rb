class MeetingsController < ApplicationController
  before_action :require_professor!
  def create
    @orientation = current_professor.orientations.find(params[:orientation_id])
    @meeting = @orientation.meetings.new(meeting_params.merge(source: "web"))
    if @meeting.save
      redirect_to orientation_path(@orientation), notice: "Registro de orientação salvo."
    else
      redirect_to orientation_path(@orientation), alert: @meeting.errors.full_messages.to_sentence
    end
  end

  private

  def meeting_params
    params.require(:meeting).permit(:held_at, :title, :transcript, :summary, :next_steps)
  end
end
