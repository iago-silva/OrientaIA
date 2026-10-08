module Api
  module V1
    class OverviewController < BaseController
      def show
        active = professor.orientations.where(status: "active")
        render json: {
          professor: { id: professor.id, name: professor.name, institution: professor.institution },
          active_students: professor.students.where(active: true).count,
          active_orientations: active.count,
          open_tasks: Task.joins(:orientation).where(orientations: { professor_id: professor.id }, status: %w[pending in_progress]).count,
          upcoming_meetings: active.where(next_meeting_at: Time.current..).order(:next_meeting_at).limit(5).includes(:student).map do |orientation|
            { orientation_id: orientation.id, student: orientation.student.name, at: orientation.next_meeting_at }
          end
        }
      end
    end
  end
end
