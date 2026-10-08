class FeedbacksController < ApplicationController
  before_action :require_professor!
  def create
    @orientation = current_professor.orientations.find(params[:orientation_id])
    @feedback = @orientation.feedbacks.new(feedback_params.merge(author_name: current_professor.name, source: "web"))
    if @feedback.save
      redirect_to orientation_path(@orientation), notice: "Devolutiva registrada."
    else
      redirect_to orientation_path(@orientation), alert: @feedback.errors.full_messages.to_sentence
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:content)
  end
end
