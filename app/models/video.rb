class Video < ApplicationRecord
  belongs_to :organization
  belongs_to :user

  # videoモデルにvideoを添付
  has_one_attached :video

  validates :video, presence: true
  validates :title, presence: true
end
