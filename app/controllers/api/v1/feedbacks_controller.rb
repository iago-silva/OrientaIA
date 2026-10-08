module Api
  module V1
    class FeedbacksController < BaseController
      before_action :set_orientation

      def index
        render json: { data: @orientation.feedbacks.map { |feedback| feedback_json(feedback) } }
      end

      def create
        feedback = @orientation.feedbacks.new(feedback_params.merge(author_name: "Assistente de voz", source: "robot"))
        if feedback.save
          render json: { data: feedback_json(feedback) }, status: :created
        else
          render json: { error: "validation_failed", details: feedback.errors.to_hash }, status: :unprocessable_entity
        end
      end

      private

      def set_orientation
        @orientation = orientation_for(params[:orientation_id])
        render_not_found unless @orientation
      end

      def feedback_params
        params.require(:feedback).permit(:content)
      end
    end
  end
end
