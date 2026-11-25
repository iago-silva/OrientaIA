class ConsentEvent < ApplicationRecord
  belongs_to :consent
  validates :action, :actor, :term_version, presence: true
end
