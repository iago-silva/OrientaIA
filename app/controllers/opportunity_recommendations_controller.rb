class OpportunityRecommendationsController < ApplicationController
  before_action :require_student!

  def index
    @recommendations = current_student.opportunity_recommendations.order(relevance: :desc)
    @recommended_count = @recommendations.where(status: "recommended").count
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
end
