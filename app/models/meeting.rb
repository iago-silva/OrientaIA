class Meeting < ApplicationRecord
  SOURCES = %w[web robot].freeze

  belongs_to :orientation
  has_one_attached :audio_file

  validates :held_at, :title, :source, presence: true
  validates :source, inclusion: { in: SOURCES }
  validates :external_id, uniqueness: { scope: :orientation_id }, allow_blank: true
end
