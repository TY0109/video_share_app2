class Folder < ApplicationRecord
  belongs_to :organization
  belongs_to :video
  validates :name,  presence: true, length: { maximum: 10 }

  scope :current_owner_has, -> (current_user) { where(organization_id: current_user.organization_id) }
end
