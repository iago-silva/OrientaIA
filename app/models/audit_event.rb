class AuditEvent < ApplicationRecord
  belongs_to :review_record
  validates :actor, :action, :revision, presence: true
end
