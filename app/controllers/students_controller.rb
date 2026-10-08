class StudentsController < ApplicationController
  before_action :require_professor!
  before_action :set_student, only: %i[show edit update destroy]

  def index
    @students = current_professor.students.order(active: :desc, name: :asc)
  end

  def show
    redirect_to orientation_path(@student.orientation) if @student.orientation
  end

  def new
    @student = current_professor.students.new
  end

  def create
    @student = current_professor.students.new(student_params)
    if @student.save
      @student.create_orientation!(professor: current_professor, title: @student.project_title.presence || "Projeto de pesquisa")
      redirect_to orientation_path(@student.orientation), notice: "Estudante cadastrado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @student.update(student_params)
      redirect_to students_path, notice: "Dados do estudante atualizados."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @student.update!(active: false)
    redirect_to students_path, notice: "Estudante arquivado."
  end

  private

  def set_student
    @student = current_professor.students.find(params[:id])
  end

  def student_params
    params.require(:student).permit(:name, :email, :program, :research_area, :project_title, :research_problem, :objectives, :methodology, :active, :progress)
  end
end
