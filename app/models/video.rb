class Video < ApplicationRecord
  belongs_to :organization
  belongs_to :user

  has_many :comments, dependent: :destroy

  has_many :video_folders, dependent: :destroy
  has_many :folders, through: :video_folders

  has_one_attached :video

  validates :title, presence: true
  # 同一組織内で同じタイトルの動画は不可
  validates :title, uniqueness: { scope: :organization }, if: :the_same_title_video_exists?
  
  validates :video, presence: true, blob: { content_type: :video }

  before_create :upload_to_vimeo

  def the_same_title_video_exists?
    Video.where(title: title, is_valid: true).where.not(id: id)
  end

  def identify_organization_and_user(current_user)
    self.organization_id = current_user.organization.id
    self.user_id = current_user.id
  end

  def my_organization?(current_resource)
    organization_id == current_resource.organization_id
  end 

  def one_of_my_organization?(current_resource)
    current_resource.organization_viewers.find_by(organization_id: organization_id).present?
  end 

  def my_upload?(current_user)
    user_id == current_user&.id
  end

  scope :organization_specific_videos, ->(organization_id) { where(organization_id: organization_id) }
  scope :available, -> { where(is_valid: true) }

  # ビデオ検索機能
  scope :search, lambda { |search_params|
    # 検索フォームが空であれば何もしない
    return if search_params.blank?

    # ひらがな・カタカナは区別しない
    title_like(search_params[:title_like])
      .open_period_from(search_params[:open_period_from])
      .open_period_to(search_params[:open_period_to])
      .range(search_params[:range])
      .user_like(search_params[:user_name])
  }

  scope :title_like, ->(title) { where('title LIKE ?', "%#{title}%") if title.present? }
  # DBには世界時間で検索されるため9時間マイナスする必要がある
  scope :open_period_from, ->(from) { where('? <= open_period', DateTime.parse(from) - 9.hours) if from.present? }
  scope :open_period_to, ->(to) { where('open_period <= ?', DateTime.parse(to) - 9.hours) if to.present? }
  scope :range, lambda { |range|
    if range.present?
      if range == 'all'
        nil
      else
        where(range: range)
      end
    end
  }
  scope :user_like, ->(user_name) { joins(:user).where('users.name LIKE ?', "%#{user_name}%") if user_name.present? }
end
