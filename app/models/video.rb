class Video < ApplicationRecord
  require_relative '../../lib/api/vimeo_client'
  
  # vimeoへのアップロードの際に使用する一時的な属性(DBには保存しない)
  attr_accessor :video_file

  belongs_to :organization
  belongs_to :user

  has_many :comments, dependent: :destroy

  has_many :video_folders, dependent: :destroy
  has_many :folders, through: :video_folders

  validates :title, presence: true
  # 同一組織内で同じタイトルの動画は不可
  validates :title, uniqueness: { scope: :organization }, if: :the_same_title_video_exists?
  
  validates :video_file, presence: true, on: :create
  validate :video_file_format, on: :create

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
  
  # vimeoに投稿し、完了できていればtrueを返す。
  # cf https://github.com/bo-oz/vimeo_me2
  def upload_to_vimeo
    vimeo_client = VimeoClient.new
    self.data_url = vimeo_client.upload(video_file)
    true # true/falseを判定するメソッドではないが、戻り値を明示
  rescue VimeoMe2::RequestFailed => e
    # 認証エラーの場合 → ビデオSomething strange occurred. Please get in touch with the app's creator.
    # 容量オーバーの場合 → ビデオYour account doesn't have enough free space to upload this video for the current time period. Go to vimeo.com/upgrade to get more.
    errors.add(:video_file, e.message)
    # ここでfalseを返してもsave処理を続行してしまうので、代わりにthrow(:abort)し処理を停止する
    throw(:abort)
  end

  def video_file_format
    errors.add(:video_file, 'の拡張子が不正です') unless ['video/mp4', 'video/webm', 'video/quicktime', 'video/mpeg', 'video/x-ms-wmv', 'video/avi'].include?(video_file.content_type) if video_file
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
