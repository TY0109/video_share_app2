# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  # organization関連==================================================
  resources :organizations do
    scope module: :organizations do
      resources :folders
    end
    member do
      scope module: :organizations do
        resource :unsubscribe, only: %i[show update], as: :organizations_unsubscribe
        resource :admission, only: %i[show update destroy], as: :organizations_admission
        resource :payment, only: %i[new create], as: :organizations_payment
      end
    end
  end

  # =================================================================

  # system_admin関連=========================================================
  devise_for :system_admins, skip: %i[registrations], controllers: {
    sessions:  'system_admins/sessions',
    passwords: 'system_admins/passwords'
  }

  resources :system_admins, only: %i[show edit update] do
  end
  # =================================================================

  # user関連=======================================================
  devise_for :users, skip: %i[registrations], controllers: {
    sessions:      'users/sessions',
    passwords:     'users/passwords',
    confirmations: 'users/confirmations',
    registrations: 'users/registrations'
  }

  resources :users do
    member do
      scope module: :users do
        resource :unsubscribe, only: %i[show update], as: :users_unsubscribe
      end
    end
  end

  post 'users_create', to: 'users#create'
  # =================================================================

  # viewer関連==========================================================
  devise_for :viewers, controllers: {
    sessions:      'viewers/sessions',
    passwords:     'viewers/passwords',
    confirmations: 'viewers/confirmations',
    registrations: 'viewers/registrations'
  }

  resources :viewers do
    member do
      scope module: :viewers do
        resource :unsubscribe, only: %i[show update], as: :viewers_unsubscribe
      end
    end
  end
  # =================================================================

  # video関連=========================================================
  resources :videos do
    member do
      get 'popup_before'
      get 'popup_after'
    end

    resources :comments, only: %i[create update destroy] do
      resources :replies, only: %i[create update destroy]
    end
  end

  # =================================================================

  # 共通==============================================================
  # 利用規約
  get 'use' => 'use#index'
  # トップページ
  root 'use#top'
  # =================================================================

  resources :videos do
    scope module: :videos do
      resources :video_folders, only: :destroy
      # 動画検索機能
      collection do
        get 'videos/search' => 'searches#search'
      end
    end
    collection do
      scope module: :videos do
        resource :recording, only: :new
      end
    end
  end

  # 動画の論理削除(データは残すが表示しないという意味でhiddensコントローラと命名)
  scope module: :videos do
    get 'videos/:id/hidden' => 'hiddens#confirm', as: :videos_hidden
    patch 'videos/:id/withdraw' => 'hiddens#withdraw', as: :videos_withdraw
  end

  # 決済機能webhook関連
  post 'webhooks' => 'webhooks#create'

  scope module: :viewers do
    get 'videos/:video_id/video_statuses/:id/hidden' => 'hiddens#confirm', as: :video_status_hidden
    patch 'videos/:video_id/video_statuses/:id/withdraw' => 'hiddens#withdraw', as: :video_status_withdraw
  end

  resources :videos do
    member do
      scope module: :viewers do
        resources :video_statuses, only: %i[index update destroy]
      end
    end
  end
end
