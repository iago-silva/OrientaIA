module Api
  module V1
    class StudentsController < BaseController
      def index
        students = professor.students.includes(:orientation).order(:name)
        students = students.where(active: ActiveModel::Type::Boolean.new.cast(params[:active])) if params.key?(:active)
        render json: { data: students.map { |student| student_json(student) } }
      end

      def show
        student = professor.students.includes(:orientation).find_by(id: params[:id])
        return render_not_found unless student

        render json: { data: student_json(student) }
      end

      def create
        student = professor.students.new(student_params)
        if student.save
          orientation = student.create_orientation!(professor: professor, title: student.project_title.presence || "Projeto de pesquisa")
          render json: { data: student_json(student).merge(orientation_id: orientation.id) }, status: :created
        else
          render json: { error: "validation_failed", details: student.errors.to_hash }, status: :unprocessable_entity
        end
      end

      def update
        student = professor.students.find_by(id: params[:id])
        return render_not_found unless student

        if student.update(student_params)
          render json: { data: student_json(student) }
        else
          render json: { error: "validation_failed", details: student.errors.to_hash }, status: :unprocessable_entity
        end
      end

      private

      def student_params
        params.require(:student).permit(:name, :email, :program, :research_area, :project_title,
          :research_problem, :objectives, :methodology, :active, :progress)
      end
    end
  end
end
