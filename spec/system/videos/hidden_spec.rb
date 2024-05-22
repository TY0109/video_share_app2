require 'rails_helper'

RSpec.describe 'VideoHidden', type: :system, js: true do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }
  let!(:organization) { create(:organization) }
  let!(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let!(:user) { create(:user, confirmed_at: Time.now) }
  let(:uploaded_file) { fixture_file_upload('aurora.mp4', 'video/mp4') } # ActionDispatch::Http::UploadedFileオブジェクト
  let(:video_sample) { create(:video_sample, video_file: uploaded_file) }

  before do
    upload_to_vimeo_mock
    destroy_from_vimeo_mock
  end

  describe '#confirm, withdraw' do # TODO: describe名これで良い？
    context 'システム管理者がログインしている場合' do # TODO: オーナーもテストしたい
      before do
        sign_in system_admin
        visit videos_hidden_path(video_sample)
      end

      it 'レイアウトが正しく表示されること' do
        expect(page).to have_link '削除しない', href: video_path(video_sample)
        expect(page).to have_link '削除する', href: videos_withdraw_path(video_sample)
      end

      it '動画詳細ページへ戻れること' do
        click_link '削除しない'
        expect(page).to have_current_path video_path(video_sample), ignore_query: true
      end

      it '論理削除できること' do
        expect {
          click_link '削除する'
        }.to change { video_sample.reload.is_valid }.from(true).to(false)
      end
    end
  end
end
