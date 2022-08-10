class Reply < ApplicationRecord
  belongs_to :organization
  belongs_to :user
  belongs_to :viewer
  belongs_to :loginless_viewer
  belongs_to :comment
end
