module Api
  module V1
    class TasksController < BaseController
      before_action :set_orientation

      def index
        render json: { data: @orientation.tasks.map { |task| task_json(task) } }
      end

      def create
        task = @orientation.tasks.new(task_params.merge(source: "robot"))
        if task.save
          render json: { data: task_json(task) }, status: :created
        else
          render json: { error: "validation_failed", details: task.errors.to_hash }, status: :unprocessable_entity
        end
      end

      def update
        task = @orientation.tasks.find_by(id: params[:id])
        return render_not_found unless task

        attrs = task_update_params
        attrs[:completed_at] = attrs[:status] == "completed" ? Time.current : nil if attrs.key?(:status)
        if task.update(attrs)
          render json: { data: task_json(task) }
        else
          render json: { error: "validation_failed", details: task.errors.to_hash }, status: :unprocessable_entity
        end
      end

      private

      def set_orientation
        @orientation = orientation_for(params[:orientation_id])
        render_not_found unless @orientation
      end

      def task_params
        params.require(:task).permit(:title, :description, :due_on, :status)
      end

      def task_update_params
        params.require(:task).permit(:title, :description, :due_on, :status)
      end
    end
  end
end
