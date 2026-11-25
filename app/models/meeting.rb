class Meeting < ApplicationRecord
  SOURCES = %w[web robot].freeze

  belongs_to :orientation
  has_one_attached :audio_file
  has_one :review_record, dependent: :destroy
  has_many :consents, dependent: :destroy
  after_create :create_supervision_record

  validates :held_at, :title, :source, presence: true
  validates :source, inclusion: { in: SOURCES }
  validates :external_id, uniqueness: { scope: :orientation_id }, allow_blank: true
  validate :validate_audio

  def shared_content
    review_record&.status == "published" ? review_record.published_content : {}
  end

  private

  def validate_audio
    return unless audio_file.attached?
    errors.add(:audio_file, "deve ter até 50 MB") if audio_file.blob.byte_size > 50.megabytes
    allowed = %w[audio/mpeg audio/mp4 audio/x-m4a audio/wav audio/x-wav audio/wave audio/ogg audio/webm]
    errors.add(:audio_file, "deve ser MP3, M4A, WAV, OGG ou WebM") unless allowed.include?(audio_file.blob.content_type)
  end

  def create_supervision_record
    create_review_record!(orientation: orientation, title: title, kind: "meeting", original_content: { summary: summary.to_s, next_steps: next_steps.to_s, transcript: transcript.to_s }, evidence: "Registro da reunião #{title}, em #{held_at.strftime('%d/%m/%Y')}. Confira as anotações e o áudio original.")
  end
end
