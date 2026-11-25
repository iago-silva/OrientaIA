class PrivacyController < ApplicationController
  def show
    @orientation = current_student ? current_student.orientation : current_professor.orientations.find_by(id: params[:orientation]) || current_professor.orientations.first
    @meeting = @orientation&.meetings&.find_by(id: params[:meeting]) || @orientation&.meetings&.first
    @consents = @orientation ? @orientation.consents.where(meeting: @meeting).includes(:participant).order(:created_at) : Consent.none
    @work_version = @orientation&.student&.academic_works&.first&.latest_version
  end

  def update
    unless %w[grant revoke].include?(params[:decision])
      return redirect_to privacy_path, alert: "Escolha conceder ou revogar sua autorização individual."
    end
    orientation = current_student ? current_student.orientation : current_professor.orientations.find(params[:orientation_id])
    raise ActiveRecord::RecordNotFound unless orientation
    meeting = orientation.meetings.find(params[:meeting_id])
    return redirect_to privacy_path(meeting: meeting.id), alert: "O processamento externo está indisponível: provedor e política institucional não configurados." if params[:purpose] != "recording"
    consent = orientation.consents.find_or_initialize_by(meeting: meeting, participant: current_user, purpose: "recording")
    grant = params[:decision] == "grant"
    consent.transaction do
      consent.update!(granted: grant, accepted_at: grant ? Time.current : consent.accepted_at, revoked_at: grant ? nil : Time.current, scope: "Áudio e transcrição da reunião #{meeting.title}. Autorização individual; não inclui envio externo.")
      consent.consent_events.create!(action: grant ? "granted" : "revoked", actor: current_user.name, scope: consent.scope, term_version: consent.term_version)
    end
    redirect_to privacy_path(meeting: meeting.id, orientation: orientation.id), notice: grant ? "Sua autorização individual foi registrada." : "Sua autorização foi revogada para usos futuros. Registros anteriores foram preservados."
  end
end
