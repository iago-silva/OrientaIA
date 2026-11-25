class WorkVersion < ApplicationRecord
  STATUSES = %w[received reviewing revision_requested approved].freeze

  belongs_to :academic_work
  has_one_attached :file
  has_many :review_comments, dependent: :nullify
  has_many :abnt_checks, dependent: :nullify
  has_one :review_record, dependent: :destroy
  has_many :processing_requests, dependent: :destroy

  validates :version_number, numericality: { only_integer: true, greater_than: 0 }, uniqueness: { scope: :academic_work_id }
  validates :status, inclusion: { in: STATUSES }
  validates :uploaded_by, presence: true
  validates :sensitivity, inclusion: { in: %w[low moderate high sensitive] }
  validates :processing_destination, inclusion: { in: %w[local external] }
  validate :validate_upload

  private

  def validate_upload
    return unless file.attached?
    errors.add(:file, "deve ter até 25 MB") if file.blob.byte_size > 25.megabytes
    allowed = %w[application/pdf application/vnd.openxmlformats-officedocument.wordprocessingml.document]
    errors.add(:file, "deve ser PDF ou DOCX") unless allowed.include?(file.blob.content_type)
  end
end
