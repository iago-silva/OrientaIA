class Professor < ApplicationRecord
  has_secure_password

  has_many :students, dependent: :destroy
  has_many :orientations, dependent: :destroy

  normalizes :email, with: ->(email) { email.to_s.strip.downcase }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
