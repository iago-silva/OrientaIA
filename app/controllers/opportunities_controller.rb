class OpportunitiesController < ApplicationController
  def new
    @opportunity = OpportunityRecommendation.new
  end

  def create
    student = current_student || current_professor.students.find(params[:student_id])
    @opportunity = student.opportunity_recommendations.new(params.require(:opportunity_recommendation).permit(:title, :item_type, :organization, :subject, :deadline_on, :description, :website))
    if @opportunity.save
      redirect_to opportunities_destination, notice: "Chamada cadastrada. Confira prazo e fonte antes de submeter."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    scope = current_student ? current_student.opportunity_recommendations : OpportunityRecommendation.joins(:student).where(students: { professor_id: current_professor.id })
    @opportunity = scope.find(params[:id])
  end

  private

  def opportunities_destination
    current_student ? opportunity_recommendations_path : students_path
  end
end
