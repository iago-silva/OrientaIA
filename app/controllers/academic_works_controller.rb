class AcademicWorksController < ApplicationController
  before_action :require_student!
  before_action :load_work, only: %i[show compare download export]

  def index
    @works = current_student.academic_works.includes(work_versions: :file_attachment).order(:id)
    @selected_work = @works.find_by(id: params[:work]) || @works.first
    @draft = @selected_work&.latest_version
  end

  def create
    work = current_student.academic_works.new(params.require(:academic_work).permit(:title, :category, :manuscript))
    if work.save
      redirect_to academic_works_path(work: work.id), notice: "Documento criado. Envie sua primeira versão."
    else
      redirect_to academic_works_path, alert: work.errors.full_messages.to_sentence
    end
  end

  def show
    @version = params[:version].present? ? @work.work_versions.find_by!(version_number: params[:version]) : @work.work_versions.where(status: "approved").first
    @comments = @work.review_comments.where.not(published_at: nil)
    @comments = @comments.where(work_version: @version) if @version
    @comments = @comments.where(status: "open") if params[:filter] != "all"
  end

  def compare
    @versions = @work.work_versions.limit(2)
  end

  def download
    version = @work.work_versions.find(params[:version_id])
    if version.file.attached?
      send_data version.file.download, filename: version.file.filename.to_s, type: version.file.content_type, disposition: "attachment"
    else
      send_data @work.manuscript.to_s, filename: "#{@work.title.parameterize}-v#{version.version_number}.txt", type: "text/plain; charset=utf-8", disposition: "attachment"
    end
  end

  def export
    comments = @work.review_comments.where.not(published_at: nil)
    text = [ "OrientaAI — Orientações publicadas", @work.title, *comments.map { |c| "#{c.section}: #{c.content}\nValidação docente: #{c.author_name}" } ].join("\n\n")
    send_data text, filename: "orientacoes-#{@work.title.parameterize}.txt", type: "text/plain; charset=utf-8"
  end

  private

  def load_work
    @work = current_student.academic_works.find(params[:id])
  end
end
