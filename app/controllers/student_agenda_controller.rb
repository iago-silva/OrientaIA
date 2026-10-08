class StudentAgendaController < ApplicationController
  before_action :require_student!

  def index
    @orientation = current_student.orientation
    @tasks = @orientation ? @orientation.tasks.order(:due_on) : Task.none
    @upcoming_meeting = @orientation&.next_meeting_at
    @meetings = @orientation ? @orientation.meetings.order(held_at: :desc).limit(4) : Meeting.none
  end
end
