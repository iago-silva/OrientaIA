module Api
  module V1
    class OrientationsController < BaseController
      def index
        orientations = professor.orientations.includes(:student).order(:status, "students.name")
        orientations = orientations.where(status: params[:status]) if params[:status].present?
        render json: { data: orientations.map { |orientation| orientation_json(orientation) } }
      end

      def show
        orientation = orientation_for(params[:id])
        return render_not_found unless orientation

        render json: { data: orientation_json(orientation) }
      end
    end
  end
end
