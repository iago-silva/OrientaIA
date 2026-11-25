class ReviewCommentsController < ApplicationController
  before_action :require_student!
  before_action :set_work

  def create
    @comment = @work.review_comments.new(comment_params.merge(author_name: current_student.name, status: "open"))
    saved = @comment.transaction do
      if @comment.save
        current_student.orientation&.orientation_messages&.create!(author_name: current_student.name, author_role: "student", content: "Dúvida sobre #{@work.title}: #{@comment.content}")
        true
      end
    end
    if saved
      redirect_to academic_work_path(@work), notice: "Comentário enviado à orientadora."
    else
      redirect_to academic_work_path(@work), alert: @comment.errors.full_messages.to_sentence
    end
  end

  def update
    comment = @work.review_comments.where.not(published_at: nil).find(params[:id])
    if comment.update(status: "resolved")
      redirect_to academic_work_path(@work), notice: "Comentário marcado como revisado."
    else
      redirect_to academic_work_path(@work), alert: comment.errors.full_messages.to_sentence
    end
  end

  private

  def set_work
    @work = current_student.academic_works.find(params[:academic_work_id])
  end

  def comment_params
    params.require(:review_comment).permit(:content, :section)
  end
end
