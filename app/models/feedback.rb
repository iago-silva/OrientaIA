class Feedback < ApplicationRecord
  SOURCES = %w[web robot].freeze

  belongs_to :orientation

  validates :author_name, :content, :source, presence: true
  validates :source, inclusion: { in: SOURCES }
end
