class SupervisionController < ApplicationController
  before_action :require_professor!
  before_action :load_record, except: :index

  def index
    @queue = records.includes(orientation: :student).order(created_at: :desc)
    @queue = params[:tab] == "history" ? @queue.where(status: %w[published rejected]) : @queue.pending
    @record = @queue.find_by(id: params[:record]) || @queue.find_by(kind: "meeting") || @queue.first
    render :show
  end

  def show
    @queue = records.pending.order(created_at: :desc)
  end

  def update
    case params[:operation]
    when "acknowledge" then @record.acknowledge!(current_professor)
    when "source" then @record.mark_source!(current_professor)
    when "edit"
      @record.save_edit!(current_professor, params.require(:content).permit(:summary, :next_steps, :transcript), params[:justification])
    when "revert"
      @record.save_edit!(current_professor, @record.original_content, "Reversão explícita à proposta original. Nova conferência e confirmação são necessárias.")
    when "include" then @record.select_items!(current_professor, params[:items])
    when "contest" then @record.contest!(current_professor, params[:note])
    when "reject" then @record.reject!(current_professor, params[:reason], params[:items])
    when "reprocess"
      @record.with_lock do
        @record.editable!
        @record.processing_requests.create!(orientation: @record.orientation, requested_by: current_professor.name, instructions: params[:instructions], destination: "local")
        @record.event!(current_professor, "reprocessing_requested", { instructions: params[:instructions], state: "pending_local_configuration" })
      end
    when "publish"
      raise ReviewRecord::TransitionError, "Reabra a revisão e confira o escopo antes de publicar." if params[:publication_scope].blank?
      confirmations = params[:confirmations]&.permit(:read, :justification, :transcript, :scope)&.to_h || {}
      @record.publish!(current_professor, expected_revision: params[:revision], confirmations: confirmations, expected_scope: params[:publication_scope])
      return redirect_to review_decision_path(@record), notice: "Versão aprovada e publicada no espaço da orientanda."
    else
      return redirect_to review_record_path(@record), alert: "Ação de revisão inválida."
    end
    target = params[:return_to] == "flow" ? supervision_flow_path(@record, step: params[:step].presence || "review") : review_record_path(@record)
    messages = { "edit" => "Edição salva, não publicada. A seleção de itens foi limpa; confirme novamente antes de publicar.", "source" => "Trecho-fonte marcado como conferido.", "reject" => "Rejeição registrada. A proposta original foi preservada.", "reprocess" => "Solicitação pendente. Processamento local indisponível; nenhum dado foi enviado.", "contest" => "Contestação registrada no histórico." }
    redirect_to target, notice: messages.fetch(params[:operation], "Sua decisão foi registrada.")
  rescue ReviewRecord::TransitionError, ActiveRecord::RecordInvalid, ActionController::ParameterMissing => error
    redirect_to review_record_path(@record), alert: error.message
  end

  def decision
    redirect_to review_record_path(@record), alert: "Este prontuário ainda não foi publicado." unless @record.status == "published"
  end

  def flow
    @step = %w[access review confirm].include?(params[:step]) ? params[:step] : "access"
    unless %w[pending editing].include?(@record.status)
      return redirect_to(@record.status == "published" ? review_decision_path(@record) : review_trail_path(@record))
    end
    if @step != "access" && !@record.acknowledged_limits
      redirect_to supervision_flow_path(@record, step: "access"), alert: "Leia e confirme os limites antes de entrar na revisão humana."
    end
  end

  def trail; end

  private

  def records
    ReviewRecord.joins(:orientation).where(orientations: { professor_id: current_professor.id })
  end

  def load_record
    @record = records.includes(:audit_events, orientation: :student).find(params[:id])
  end
end
