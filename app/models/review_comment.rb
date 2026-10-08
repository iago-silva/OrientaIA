class ReviewComment < ApplicationRecord
  STATUSES = %w[open resolved].freeze

  belongs_to :academic_work
  belongs_to :work_version, optional: true

  validates :content, :author_name, :status, presence: true
  validates :status, inclusion: { in: STATUSES }
end
