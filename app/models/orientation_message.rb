class OrientationMessage < ApplicationRecord
  belongs_to :orientation
  validates :author_name, :author_role, :content, presence: true
  validates :content, length: { maximum: 5000 }
end
