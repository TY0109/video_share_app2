class Folder < ApplicationRecord
  belongs_to :organization
  has_many :video_folders
  validates :name,  presence: true, uniqueness: { scope: :organization }

  scope :current_owner_has, -> (current_user) { where(organization_id: current_user.organization_id) }
end
