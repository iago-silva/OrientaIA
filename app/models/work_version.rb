class WorkVersion < ApplicationRecord
  STATUSES = %w[received reviewing revision_requested approved].freeze

  belongs_to :academic_work
  has_one_attached :file
  has_many :review_comments, dependent: :nullify
  has_many :abnt_checks, dependent: :nullify

  validates :version_number, numericality: { only_integer: true, greater_than: 0 }, uniqueness: { scope: :academic_work_id }
  validates :status, inclusion: { in: STATUSES }
  validates :uploaded_by, presence: true
end
