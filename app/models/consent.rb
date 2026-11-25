class Consent < ApplicationRecord
  belongs_to :orientation
  belongs_to :meeting, optional: true
  belongs_to :participant, polymorphic: true
  has_many :consent_events, dependent: :destroy
  validates :purpose, inclusion: { in: %w[recording external] }
  validates :participant_id, uniqueness: { scope: %i[participant_type orientation_id purpose meeting_id] }
  validate :participant_belongs_to_orientation

  def active?
    granted? && revoked_at.nil?
  end

  private

  def participant_belongs_to_orientation
    return unless orientation && participant
    allowed = participant == orientation.professor || participant == orientation.student
    errors.add(:participant, "não participa desta orientação") unless allowed
    errors.add(:meeting, "não pertence à orientação") if meeting && meeting.orientation_id != orientation_id
  end
end
