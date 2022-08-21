require 'rails_helper'

RSpec.describe Video, type: :system do
  # FactoryBotで作成したorganizationとuserをDBに登録
  let(:organization) { create(:organization) }
  # confirmed_at: Time.nowがないと、テストログインできないので注意
  let!(:user) { create(:user, confirmed_at: Time.now) }

  # CRUD
  describe 'Video CRUD' do
    describe 'ログイン後' do
      before(:each) { sign_in user }

      describe 'ビデオ新規登録' do
        context 'フォームの入力値が正常' do
          it 'ビデオの新規作成が成功' do
            # ビデオ新規作成画面へ遷移
            visit new_video_path
            # titleテキストフィールドにあああと入力。fill_inの値は、ビューのフォームのfieldのid
            fill_in 'title', with: 'あああ'
            # spec/fixtures/filesフォルダに入れたビデオをアップロード
            fixture_file_upload('/rec.webm')
            fill_in 'open_period', with: 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00'
            # selectへの対応表記
            expect(page).to have_selector '#range', text: false
            expect(page).to have_selector '#comment_public', text: false
            expect(page).to have_selector '#popup_before_video', text: false
            expect(page).to have_selector '#popup_after_video', text: false
            # hiddenへの対応表記
            find_field(id: 'video_organization_id', type: :hidden).set(user.organization.id)
            find_field(id: 'video_user_id', type: :hidden).set(user.id)
            click_button '新規投稿'
            # videos_pathへ遷移することを期待する
            expect(page).to have_current_path videos_path, ignore_query: true
          end
        end
      end
    end
  end
end
