class AbntAnalysesController < ApplicationController
  before_action :require_student!

  def show
    @checks = AbntCheck.joins(:academic_work).where(academic_works: { student_id: current_student.id })
    category = params[:category].presence || "Citações"
    @filtered = category == "all" ? @checks : @checks.where(category: category)
    @findings = @filtered.where(status: %w[suggestion manual_review]).order(:code)
  end

  def export
    checks = AbntCheck.joins(:academic_work).where(academic_works: { student_id: current_student.id })
    text = [ "OrientaAI — Verificação ABNT assistida", "Apoio à conferência humana; não é certificação de conformidade.", *checks.map { |c| "#{c.code} · #{c.title}\n#{c.recommendation}\nConferência humana: #{c.human_checked_at ? 'registrada' : 'pendente'}" } ].join("\n\n")
    send_data text, filename: "relatorio-abnt.txt", type: "text/plain; charset=utf-8"
  end
end
