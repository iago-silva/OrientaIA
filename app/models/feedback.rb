class Feedback < ApplicationRecord
  has_one :review_record, dependent: :destroy
  after_create :create_supervision_record
  SOURCES = %w[web robot].freeze

  belongs_to :orientation

  validates :author_name, :content, :source, presence: true
  validates :source, inclusion: { in: SOURCES }
  private

  def create_supervision_record
    create_review_record!(orientation: orientation, title: content.to_s.lines.first.to_s.truncate(100), kind: "feedback", original_content: { summary: content, next_steps: "", transcript: "" }, evidence: "Devolutiva registrada em #{Time.current.strftime('%d/%m/%Y')}. Confira o contexto da orientação.")
  end
end
