module Api
  module V1
    class MeetingsController < BaseController
      before_action :set_orientation

      def index
        render json: { data: @orientation.meetings.map { |meeting| meeting_json(meeting) } }
      end

      def create
        if meeting_params[:external_id].present?
          existing = @orientation.meetings.find_by(external_id: meeting_params[:external_id])
          return render json: { data: meeting_json(existing), duplicate: true }, status: :ok if existing
        end

        meeting = @orientation.meetings.new(meeting_params.merge(source: "robot"))
        if meeting.save
          render json: { data: meeting_json(meeting) }, status: :created
        elsif meeting.persisted?
          render json: { error: "duplicate_event", message: "external_id já registrado para esta orientação." }, status: :conflict
        else
          render json: { error: "validation_failed", details: meeting.errors.to_hash }, status: :unprocessable_entity
        end
      end

      private

      def set_orientation
        @orientation = orientation_for(params[:orientation_id])
        render_not_found unless @orientation
      end

      def meeting_params
        params.require(:meeting).permit(:held_at, :title, :transcript, :summary, :next_steps, :external_id)
      end
    end
  end
end
