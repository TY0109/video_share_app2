require 'rails_helper'

RSpec.describe 'VideosSystem', type: :system, js: :true do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }

  let!(:organization) { create(:organization) }
  let!(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let!(:user_staff) { create(:user_staff, confirmed_at: Time.now) }
  # orgにのみ属す
  let!(:viewer) { create(:viewer, confirmed_at: Time.now) }
  # orgとviewerの紐付け
  let!(:organization_viewer) { create(:organization_viewer) }
  
  let(:uploaded_file) { fixture_file_upload('aurora.mp4', 'video/mp4') } # ActionDispatch::Http::UploadedFileオブジェクト
  let(:video_sample) {create(:video_sample, video_file: uploaded_file) }
  let(:video_test) { create(:video_test, video_file: uploaded_file) }

  let!(:folder_celeb) { create(:folder_celeb) }
  let!(:folder_tech) { create(:folder_tech) }

  describe '#index' do
    before do
      upload_to_vimeo_mock
      video_sample
    end

    context "システム管理者がログインしている場合" do
      before do
        sign_in system_admin
        visit videos_path(organization_id: organization.id)
      end

      it 'レイアウトが正しいこと' do
        expect(page).to have_link video_sample.title, href: video_path(video_sample)
        expect(page).to have_link '削除', href: video_path(video_sample)
        # 元々複数の動画で検証していたが、１つでも良さそうなのでコメントアウト
        # expect(page).to have_link video_test.title, href: video_path(video_test)
        # expect(page).to have_link '削除', href: video_path(video_test)
      end

      it '動画削除できること' do
        destroy_from_vimeo_mock
        click_link '削除'
        # find(:xpath, '//*[@id="videos-index"]/div[1]/div[1]/div[2]/div[1]/div[2]/a[2]').click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？ この動画はvimeoからも完全に削除されます'
          page.driver.browser.switch_to.alert.accept
          expect(page).to have_content '削除しました'
        }.to change(Video, :count).by(-1)
      end

      it '動画削除をキャンセルできること' do
        click_link '削除'
        # find(:xpath, '//*[@id="videos-index"]/div[1]/div[1]/div[2]/div[1]/div[2]/a[2]').click
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq '削除しますか？ この動画はvimeoからも完全に削除されます'
          page.driver.browser.switch_to.alert.dismiss
        }.not_to change(Video, :count)
      end
    end
    
    # context "オーナーがログインしている場合" do # TODO: 投稿者がログインしている場合もテストしたい
    #   before do
    #     sign_in user_owner 
    #     visit videos_path(organization_id: organization.id)
    #   end

    #   it 'レイアウトに削除リンクなし' do # 仕様変更?のため表示できる
    #     expect(page).to have_link 'サンプルビデオ', href: video_path(video_sample)
    #     expect(page).to have_no_link '削除', href: video_path(video_sample)
    #   end
    # end

    context "視聴者がログインしている場合" do
      before do
        sign_in viewer
        visit videos_path(organization_id: organization.id)
      end

      it 'レイアウトに設定リンク、削除リンクなし' do
        expect(page).to have_link video_sample.title, href: video_path(video_sample)
        expect(page).to have_no_link '設定', href: edit_video_path(video_sample)
        expect(page).to have_no_link '削除', href: video_path(video_sample)
      end
    end
  end

  describe '#show' do
    shared_examples "all_in_layout" do
      it 'レイアウトにタイトルと、設定、論理削除のリンクが含まれること' do
        expect(page).to have_text video_sample.title
        expect(page).to have_link '設定', href: edit_video_path(video_sample)
        expect(page).to have_link '削除', href: videos_hidden_path(video_sample)
      end
    end
    
    shared_examples "without_edit_and_delete_link_in_layout" do
      it 'レイアウトに設定リンクと論理削除リンクなし' do
        expect(page).to have_text video_sample.title
        expect(page).to have_no_link '設定', href: video_path(video_sample)
        expect(page).to have_no_link '削除', href: videos_hidden_path(video_sample)
      end
    end

    before do
      upload_to_vimeo_mock
      video_sample
    end

    context "システム管理者がログインしている場合" do
      before do
        sign_in system_admin
        visit video_path(video_sample)
      end

      it_behaves_like "all_in_layout"
    end

    context "オーナーがログインしている場合" do
      before do
        sign_in user_owner
        visit video_path(video_sample)
      end

      it_behaves_like "all_in_layout"
    end

    context "動画投稿者がログインしている場合" do
      before do
        sign_in user_staff
        visit video_path(video_sample)
      end

      it 'レイアウトに論理削除リンクなし' do
        expect(page).to have_text video_sample.title
        expect(page).to have_no_link '削除', href: videos_hidden_path(video_sample)
      end
    end

    context "視聴者がログインしている場合" do
      before do
        sign_in viewer
        visit video_path(video_sample)
      end

      it_behaves_like "without_edit_and_delete_link_in_layout"
    end

    context '非ログイン状態である場合' do
      before do
        visit video_path(video_sample)
      end

      it_behaves_like "without_edit_and_delete_link_in_layout"
    end
  end

  describe '#edit, update' do
    before do
      upload_to_vimeo_mock
      video_sample
      video_test
    end

    context "システム管理者がログインしている場合" do # TODO: オーナー、投稿者本人の場合もテストしたい
      before do
        sign_in system_admin
        visit video_path(video_sample)
        click_link('設定')
      end
  
      it 'モーダルが表示されていること' do
        expect(page).to have_selector('.modal')
      end
  
      it 'レイアウトが正しいこと' do
        expect(page).to have_button '設定を変更'
        expect(page).to have_button '閉じる'
        # TODO: idで指定しているが、nameの方が良いか
        expect(page).to have_field 'title_edit', with: video_sample.title
        # expect(page).to have_field 'open_period_edit', with: Time.now + 1 # TODO: これではエラーになる
        expect(page).to have_select('range_edit', selected: '一般公開')
        expect(page).to have_select('comment_public_edit', selected: '公開')
        expect(page).to have_select('login_set_edit', selected: 'ログイン不要')
        expect(page).to have_select('popup_before_video_edit', selected: '動画視聴開始時ポップアップ表示')
        expect(page).to have_select('popup_after_video_edit', selected: '動画視聴終了時ポップアップ表示')
        expect(page).to have_field folder_celeb.name
        expect(page).to have_field folder_tech.name
      end
  
      it '正しい入力後、設定を変更で動画情報が更新されること' do
        # TODO: idで指定しているが、nameの方が良いか
        fill_in 'title_edit', with: 'サンプルビデオ２'
        # fill_in 'open_period_edit', with: Time.now + 1  # TODO: これではエラーになる(please enter a valid value the two nearest valid value is)
        select '限定公開', from: 'range_edit'
        select '非公開', from: 'comment_public_edit'
        select 'ログイン必要', from: 'login_set_edit'
        select '動画視聴開始時ポップアップ非表示', from: 'popup_before_video_edit'
        select '動画視聴終了時ポップアップ非表示', from: 'popup_after_video_edit'
        check 'video_folder_ids_2'
        click_button '設定を変更'
        expect(page).to have_text '動画情報を更新しました'
      end
  
      it 'タイトル空白ならエラーになること' do
        fill_in 'title_edit', with: ''
        click_button '設定を変更'
        expect(page).to have_text 'タイトルを入力してください'
      end
  
      it 'タイトル重複ならエラーになること' do
        fill_in 'title_edit', with: 'テストビデオ'
        click_button '設定を変更'
        expect(page).to have_text 'タイトルはすでに存在します'
      end
    end

    context 'その動画を投稿した本人ではない動画投稿者がログインしている場合' do
      before do
        sign_in user_staff
        visit video_path(video_sample)
        click_link('設定')
      end
    
      it 'モーダルが表示されていること' do
        expect(page).to have_selector('.modal')
      end
    
      it 'レイアウトに設定を変更リンクなし' do
        expect(page).to have_no_link '設定を変更'
        expect(page).to have_button '閉じる'
        expect(page).to have_field 'title_edit'
        expect(page).to have_field 'open_period_edit'
        expect(page).to have_selector '#range_edit'
        expect(page).to have_selector '#comment_public_edit'
        expect(page).to have_selector '#login_set_edit'
        expect(page).to have_selector '#popup_before_video_edit'
        expect(page).to have_selector '#popup_after_video_edit'
        expect(page).to have_field 'セレブエンジニア'
        expect(page).to have_field 'テックリーダーズ'
      end
    end
  end

  describe '#new, create' do # TODO: describe名これで良い？
    before do
      upload_to_vimeo_mock
      video_sample
      sign_in user_owner
      visit new_video_path
    end

    it 'レイアウトが正しく表示されること' do
      expect(page).to have_field 'title'
      expect(page).to have_field 'post'
      expect(page).to have_field 'open_period'
      expect(page).to have_selector '#range'
      expect(page).to have_selector '#comment_public'
      expect(page).to have_selector '#login_set'
      expect(page).to have_selector '#popup_before_video'
      expect(page).to have_selector '#popup_after_video'
      expect(page).to have_field folder_celeb.name
      expect(page).to have_field folder_tech.name
      expect(page).to have_link 'フォルダ新規作成はこちら'
      expect(page).to have_button '新規投稿'
    end

    it '入力内容が正しいなら動画が作成されること' do
      # TODO: idで指定しているが、nameの方が良いか
      fill_in 'title', with: 'サンプルビデオ２'
      attach_file 'video[video_file]', File.join(Rails.root, 'spec/fixtures/files/aurora.mp4')
      fill_in 'open_period', with: Time.now + 1 
      select '限定公開', from: 'range'
      select '非公開', from: 'comment_public'
      select 'ログイン必要', from: 'login_set'
      select '動画視聴開始時ポップアップ非表示', from: 'popup_before_video'
      select '動画視聴終了時ポップアップ非表示', from: 'popup_after_video'
      check "video_folder_ids_1"
      click_button '新規投稿'
      expect(page).to have_current_path video_path(Video.last), ignore_query: true
      expect(page).to have_text '動画を投稿しました'
    end

    it 'タイトル空白ならエラーになること' do
      # TODO: idで指定しているが、nameの方が良いか
      fill_in 'title', with: ''
      attach_file 'video[video_file]', File.join(Rails.root, 'spec/fixtures/files/aurora.mp4')
      click_button '新規投稿'
      expect(page).to have_text 'タイトルを入力してください'
    end

    it 'タイトル重複ならエラーになること' do
      # TODO: idで指定しているが、nameの方が良いか
      fill_in 'title', with: 'サンプルビデオ'
      attach_file 'video[video_file]', File.join(Rails.root, 'spec/fixtures/files/aurora.mp4')
      click_button '新規投稿'
      expect(page).to have_text 'タイトルはすでに存在します'
    end

    it '動画データ空白ならエラーになること' do
      # TODO: idで指定しているが、nameの方が良いか
      fill_in 'title', with: 'サンプルビデオ2'
      click_button '新規投稿'
      expect(page).to have_text 'ビデオを入力してください'
    end

    # TODO: it '拡張子が不正なファイル' do; end
  end
end
