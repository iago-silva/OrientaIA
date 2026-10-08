class WorkVersionsController < ApplicationController
  before_action :require_student!

  def create
    @work = current_student.academic_works.find(params[:academic_work_id])
    if params.dig(:work_version, :file).blank?
      return redirect_to academic_work_path(@work), alert: "Selecione o arquivo da nova versão."
    end

    upload = params.dig(:work_version, :file)
    allowed_types = %w[application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document]
    if upload.size > 20.megabytes || !allowed_types.include?(upload.content_type)
      return redirect_to academic_work_path(@work), alert: "Envie um PDF ou Word de até 20 MB."
    end

    @version = @work.work_versions.new(version_params.merge(
      version_number: @work.work_versions.maximum(:version_number).to_i + 1,
      uploaded_by: "student",
      status: "received",
      label: "Nova revisão"
    ))

    if @version.save
      @version.file.attach(params[:work_version][:file]) if params.dig(:work_version, :file).present?
      @work.update!(current_version: @version.version_number, status: "submitted", submitted_at: Time.current)
      redirect_to academic_work_path(@work), notice: "Nova versão enviada para revisão."
    else
      redirect_to academic_work_path(@work), alert: @version.errors.full_messages.to_sentence
    end
  end

  private

  def version_params
    params.require(:work_version).permit(:change_note)
  end
end
