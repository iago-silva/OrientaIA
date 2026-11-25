class ProcessingRequest < ApplicationRecord
  belongs_to :orientation
  belongs_to :review_record, optional: true
  belongs_to :work_version, optional: true
  validates :requested_by, :instructions, presence: true
  validates :destination, inclusion: { in: %w[local external] }
  validates :status, inclusion: { in: %w[pending blocked completed] }
end
