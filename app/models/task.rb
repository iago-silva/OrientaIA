class Task < ApplicationRecord
  STATUSES = %w[pending in_progress completed].freeze
  SOURCES = %w[web robot].freeze

  belongs_to :orientation

  validates :title, :status, :source, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :source, inclusion: { in: SOURCES }

  def status_label
    { "pending" => "Pendente", "in_progress" => "Em andamento", "completed" => "Concluída" }.fetch(status)
  end
end
