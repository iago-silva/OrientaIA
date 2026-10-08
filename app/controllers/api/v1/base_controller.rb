module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_robot!

      private

      attr_reader :professor

      def authenticate_robot!
        expected = ENV["ROBOT_API_TOKEN"]
        expected = "demo-robot-token" if Rails.env.development? && expected.blank?
        supplied = request.authorization.to_s.delete_prefix("Bearer ")
        if expected.blank?
          render json: { error: "api_token_not_configured" }, status: :service_unavailable
        elsif supplied.blank? || !ActiveSupport::SecurityUtils.secure_compare(supplied, expected)
          render json: { error: "unauthorized", message: "Use Authorization: Bearer <token>." }, status: :unauthorized
        else
          @professor = Professor.order(:id).first
          render json: { error: "demo_professor_not_configured" }, status: :service_unavailable unless @professor
        end
      end

      def render_not_found
        render json: { error: "not_found" }, status: :not_found
      end

      def orientation_for(id)
        professor.orientations.includes(:student).find_by(id: id)
      end

      def student_json(student)
        { id: student.id, name: student.name, email: student.email, program: student.program,
          research_area: student.research_area, project_title: student.project_title,
          research_problem: student.research_problem, objectives: student.objectives,
          methodology: student.methodology, active: student.active, progress: student.progress,
          orientation_id: student.orientation&.id }
      end

      def orientation_json(orientation)
        { id: orientation.id, title: orientation.title, status: orientation.status,
          next_meeting_at: orientation.next_meeting_at, notes: orientation.notes,
          student: { id: orientation.student.id, name: orientation.student.name, program: orientation.student.program } }
      end

      def task_json(task)
        { id: task.id, title: task.title, description: task.description, due_on: task.due_on,
          status: task.status, source: task.source, completed_at: task.completed_at }
      end

      def meeting_json(meeting)
        { id: meeting.id, held_at: meeting.held_at, title: meeting.title, transcript: meeting.transcript,
          summary: meeting.summary, next_steps: meeting.next_steps, source: meeting.source,
          external_id: meeting.external_id }
      end

      def feedback_json(feedback)
        { id: feedback.id, author_name: feedback.author_name, content: feedback.content,
          source: feedback.source, created_at: feedback.created_at }
      end
    end
  end
end
