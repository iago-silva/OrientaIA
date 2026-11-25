class ProcessingRequestsController < ApplicationController
  before_action :require_student!

  def create
    version = WorkVersion.joins(:academic_work).where(academic_works: { student_id: current_student.id }).find(params[:work_version_id])
    unless current_student.orientation
      return redirect_to academic_works_path(work: version.academic_work_id), alert: "A análise está bloqueada. Peça à sua orientadora para vincular sua orientação; o documento foi preservado."
    end
    version.processing_requests.create!(orientation: current_student.orientation, requested_by: current_student.name, instructions: "Análise solicitada para #{version.academic_work.title}. Mantida pendente por indisponibilidade do ambiente local.", destination: "local", status: "blocked")
    redirect_to academic_works_path(work: version.academic_work_id), alert: "Análise indisponível: ambiente local não configurado. O rascunho está salvo; nenhum dado foi enviado a um provedor externo."
  end
end
