class Website < ApplicationRecord
  validates :firebase_project_id, uniqueness: true

  extend FriendlyId
  friendly_id :firebase_project_id, use: :slugged
end
