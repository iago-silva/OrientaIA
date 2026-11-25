class Orientation < ApplicationRecord
  STATUSES = %w[active paused completed].freeze

  belongs_to :professor
  belongs_to :student
  has_many :meetings, -> { order(held_at: :desc) }, dependent: :destroy
  has_many :tasks, -> { order(due_on: :asc, created_at: :desc) }, dependent: :destroy
  has_many :feedbacks, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :review_records, dependent: :destroy
  has_many :consents, dependent: :destroy
  has_many :processing_requests, dependent: :destroy
  has_many :orientation_messages, dependent: :destroy

  validates :title, :status, presence: true
  validates :status, inclusion: { in: STATUSES }
  validate :student_belongs_to_professor

  private

  def student_belongs_to_professor
    return if student.blank? || professor.blank? || student.professor_id == professor_id

    errors.add(:student, "precisa pertencer a este professor")
  end
end
