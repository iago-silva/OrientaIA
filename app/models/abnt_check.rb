class AbntCheck < ApplicationRecord
  STATUSES = %w[verified suggestion manual_review].freeze

  belongs_to :academic_work
  belongs_to :work_version, optional: true

  validates :code, :category, :title, :status, presence: true
  validates :status, inclusion: { in: STATUSES }
end
