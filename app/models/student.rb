class Student < ApplicationRecord
  has_secure_password validations: false

  PROGRAMS = [ "Mestrado", "Doutorado" ].freeze

  belongs_to :professor
  has_one :orientation, dependent: :destroy
  has_many :academic_works, dependent: :destroy
  has_many :opportunity_recommendations, dependent: :destroy

  normalizes :email, with: ->(email) { email.to_s.strip.downcase }

  validates :name, :email, :program, presence: true
  validates :email, uniqueness: { scope: :professor_id }
  validates :program, inclusion: { in: PROGRAMS }
  validates :progress, numericality: { only_integer: true, in: 0..100 }
end
