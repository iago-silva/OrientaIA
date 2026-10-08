class AcademicWork < ApplicationRecord
  STATUSES = %w[draft submitted reviewed].freeze

  belongs_to :student
  has_many :work_versions, -> { order(version_number: :desc) }, dependent: :destroy
  has_many :review_comments, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :abnt_checks, -> { order(:category, :code) }, dependent: :destroy

  validates :title, :category, :status, presence: true
  validates :status, inclusion: { in: STATUSES }

  def latest_version
    work_versions.first
  end

  def open_comments_count
    review_comments.where(status: "open").count
  end
end
