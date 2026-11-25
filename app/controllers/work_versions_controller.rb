class WorkVersionsController < ApplicationController
  before_action :require_student!

  def create
    work = current_student.academic_works.find(params[:academic_work_id])
    permitted = params.require(:work_version).permit(:file, :change_note, :sensitivity, :processing_destination)
    return redirect_to academic_works_path(work: work.id), alert: "Selecione um arquivo PDF ou DOCX de até 25 MB." if permitted[:file].blank?
    if permitted[:processing_destination] == "external"
      return redirect_to academic_works_path(work: work.id), alert: "Envio externo indisponível. Preserve o rascunho com destino local."
    end
    work.with_lock do
      version = work.work_versions.new(permitted.merge(version_number: work.work_versions.maximum(:version_number).to_i + 1, label: "Rascunho de envio", status: "received", uploaded_by: "student"))
      if version.save
        work.update!(current_version: version.version_number, status: "draft")
        redirect_to academic_works_path(work: work.id), notice: "Rascunho salvo. Nenhuma análise ou transmissão externa foi iniciada. As versões anteriores foram preservadas."
      else
        redirect_to academic_works_path(work: work.id), alert: version.errors.full_messages.to_sentence
      end
    end
  end
end
