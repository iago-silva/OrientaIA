class OpportunityRecommendationsController < ApplicationController
  before_action :require_student!

  def index
    @total_count = current_student.opportunity_recommendations.count
    @recommended_count = current_student.opportunity_recommendations.where.not(recommended_by: nil).count
    @recommendations = current_student.opportunity_recommendations
    @recommendations = @recommendations.where.not(recommended_by: nil) if params[:filter] == "recommended"
    @recommendations = @recommendations.where(item_type: params[:type]) if %w[journal congress event].include?(params[:type])
    if params[:q].present?
      @recommendations = @recommendations.where("title LIKE ? OR subject LIKE ?", "%#{params[:q]}%", "%#{params[:q]}%")
    end
    @recommendations = @recommendations.where("deadline_on >= ?", Date.current) if params[:deadline] == "open"
    @recommendations = @recommendations.where("deadline_on < ?", Date.current) if params[:deadline] == "closed"
    @recommendations = params[:sort] == "deadline" ? @recommendations.order(deadline_on: :asc, id: :asc) : @recommendations.order(relevance: :desc, id: :asc)
    @selected = @recommendations.find_by(id: params[:selected]) || @recommendations.first
  end

  def update
    recommendation = current_student.opportunity_recommendations.find(params[:id])
    status = params.dig(:opportunity_recommendation, :status)
    unless OpportunityRecommendation::STATUSES.include?(status)
      return redirect_to opportunity_recommendations_path, alert: "Escolha uma ação válida."
    end

    recommendation.update!(status: status)
    redirect_to opportunity_recommendations_path, notice: "Sua lista de submissões foi atualizada."
  end

  def recommend
    recommendation = current_student.opportunity_recommendations.find(params[:id])
    recommendation.update!(recommended_by: "#{current_student.name} · prévia demonstrativa", message: params[:message].presence || "Confira esta oportunidade com sua orientadora.", preparation_on: params[:preparation_on].presence, status: "recommended")
    redirect_to opportunity_recommendations_path(selected: recommendation.id), notice: "Recomendação demonstrativa registrada no acompanhamento. Nenhuma submissão externa foi realizada."
  rescue ActiveRecord::RecordInvalid
    redirect_to opportunity_recommendations_path, alert: "Confira os dados da recomendação."
  end

  def acknowledge
    current_student.opportunity_recommendations.find(params[:id]).update!(acknowledged_at: Time.current)
    redirect_to opportunity_recommendations_path, notice: "Ciência registrada."
  end
end
