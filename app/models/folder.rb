class Folder < ApplicationRecord
  belongs_to :organization
  belongs_to :video
  validates :name,  presence: true, length: { maximum: 10 }
end
