require 'rails_helper'

RSpec.describe 'Videos', type: :request do
  # FactoryBotで作成したuserをDBに登録
  let!(:user) { create(:user, confirmed_at: Time.now) }
  let!(:video) { create(:video) }

  describe 'GET /index' do
    it 'returns http success' do
      sign_in user
      get '/videos'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /new' do
    it 'returns http success' do
      sign_in user
      get '/videos/new'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /show' do
    it 'returns http success' do
      get '/videos/1'
      expect(response).to have_http_status(:success)
    end
  end

  # describe 'GET /edit' do
  # ビュー、アクションともに未作成のため未実施
  # end
end
