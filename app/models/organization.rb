class Organization < ApplicationRecord
  has_many :users, dependent: :destroy, autosave: true
  has_many :organization_viewers, dependent: :destroy
  has_many :viewers, through: :organization_viewers
  has_many :folders, dependent: :destroy
  has_many :videos, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :replies, dependent: :destroy

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
  validates :name,  presence: true, length: { in: 1..10 }
  validates :plan, inclusion: { in: [-1, 0, 1000, 2000] }, allow_nil: true
  validates :customer_id, uniqueness: true, allow_nil: true
  validates :subscription_id, uniqueness: true, allow_nil: true

  # 引数のviewer_idと一致するorganizationの絞り込み
  scope :viewer_has, ->(viewer_id) { includes(:organization_viewers).where(organization_viewers: { viewer_id: viewer_id }) }
  scope :viewer_existence_confirmation, ->(viewer_id) { find_by(organization_viewers: { viewer_id: viewer_id }) }

  # 組織に属するオーナーを紐づける
  class << self
    def build(params)
      organization = new(name: params[:name], email: params[:email])
      organization.users.build(params[:users])
      organization
    end
  end

  # 組織の退会時、所属者全員退会にするメソッド
  def self.bulk_update(organization_id)
    all_valid = true
    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      organization = Organization.find(organization_id).update(is_valid: false)
      user = User.user_has(organization_id).update(is_valid: false)

      # 視聴者は複数の組織へ所属できる為、脱退処理
      organization_viewers = OrganizationViewer.where(organization_id: organization_id)
      organization_viewers.each(&:destroy)

      all_valid &= organization && user && organization_viewers
      # 全ての処理が有効出ない場合ロールバックする
      unless all_valid
        raise ActiveRecord::Rollback
      end
    end
    all_valid
  end

  # 支払い失敗を判定するメソッド
  def payment_failed?
    plan.nil? || plan == -1
  end

  def my_organization?(current_resource)
    id == current_resource.organization_id
  end 

  def one_of_my_organization?(current_resource)
    current_resource.organization_viewers.find_by(organization_id: id).present?
  end 
end
