class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :viewer
  belongs_to :loginless_viewer
  belongs_to :organization
  belongs_to :video

  has_many :replies

  # バリデーション
  validates :comment, presence: true
  
end
