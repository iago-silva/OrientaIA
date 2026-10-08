class OpportunityRecommendation < ApplicationRecord
  STATUSES = %w[recommended saved dismissed].freeze

  belongs_to :student

  validates :title, :item_type, :status, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :relevance, numericality: { only_integer: true, in: 0..100 }
end
