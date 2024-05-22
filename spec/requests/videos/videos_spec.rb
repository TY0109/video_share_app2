require 'rails_helper'

RSpec.describe 'Videos', type: :request do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) } # メール認証をskipして作成するには、confirmed_atに値が必要なのでセット

  let!(:organization) { create(:organization) }
  let!(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let!(:user_staff) { create(:user_staff, confirmed_at: Time.now) }

  let!(:another_organization) { create(:another_organization) }
  let!(:another_user_owner) { create(:another_user_owner, confirmed_at: Time.now) }

  # orgにのみ属す
  let!(:viewer) { create(:viewer, confirmed_at: Time.now) }
  # another_orgにのみ属す
  let!(:another_viewer) { create(:viewer1, confirmed_at: Time.now) }
  # orgとviewerの紐付け
  let!(:organization_viewer) { create(:organization_viewer) }
  
  let(:uploaded_file) { fixture_file_upload('aurora.mp4', 'video/mp4') } # ActionDispatch::Http::UploadedFileオブジェクト
  let(:video_sample) { create(:video_sample, video_file: uploaded_file) }
  let(:video_test) { create(:video_test, video_file: uploaded_file) }

  shared_examples "access_success" do
    it 'レスポンスに成功すること' do
      expect(response).to have_http_status(:success)
    end
  
    it '正常値レスポンスを返すこと' do
      expect(response).to have_http_status :ok
    end
  end

  shared_examples "access_failure" do
    it 'アクセス権限なしのためリダイレクトすること' do
      expect(response).to have_http_status :found
      expect(response).to redirect_to root_path
    end
  end

  describe 'GET #index' do
    context '動画投稿者がログインしている場合' do
      before do
        sign_in user_staff
        get videos_path(organization_id: organization.id)
      end

      it_behaves_like "access_success"
    end

    context 'オーナーがログインしている場合' do
      before do
        sign_in user_owner
        get videos_path(organization_id: organization.id)
      end

      it_behaves_like "access_success"
    end

    context 'システム管理者がログインしている場合' do
      before do
        sign_in system_admin
        get videos_path(organization_id: organization.id)
      end

      it_behaves_like "access_success"
    end

    context '視聴者がログインしている場合' do
      before do
        organization_viewer
        sign_in viewer
        get videos_path(organization_id: organization.id)
      end

      it_behaves_like "access_success"
    end

    context '別組織のuserがログインしている場合' do
      before do
        sign_in user_owner
        get videos_path(organization_id: another_organization.id)
      end

      it_behaves_like "access_failure"
    end

    context '別組織の視聴者がログインしている場合' do
      before do
        sign_in viewer
        get videos_path(organization_id: another_organization.id)
      end

      it_behaves_like "access_failure"
    end

    context '非ログイン状態の場合' do
      before do
        get videos_path(organization_id: another_organization.id)
      end

      it_behaves_like "access_failure"
    end
  end

  describe 'GET #new' do
    context '動画投稿者がログインしている場合' do
      before do
        sign_in user_staff
        get new_video_path
      end

      it_behaves_like "access_success"
    end

    context 'オーナーがログインしている場合' do
      before do
        sign_in user_owner
        get new_video_path
      end

      it_behaves_like "access_success"
    end

    context 'システム管理者がログインしている場合' do
      before do
        sign_in system_admin
        get new_video_path
      end

      it_behaves_like "access_failure"
    end

    context '視聴者がログインしている場合' do
      before do
        sign_in viewer
        get new_video_path
      end

      it_behaves_like "access_failure" 
    end

    context '非ログイン状態の場合' do
      before do
        get videos_path(organization_id: another_organization.id)
      end

      it_behaves_like "access_failure"
    end
  end

  describe 'POST #create' do
    shared_examples "can_create" do
      # TODO: titleとvideo_file以外のカラムの入力についてはテストできていない
      it '動画が新規作成される' do
        expect {
          post(videos_path, params: valid_params)
        }.to change(Video, :count).by(1)
      end
    end

    shared_examples "redirect_to_show" do
      it 'showページにリダイレクトする' do
        post(videos_path, params: valid_params)
        expect(response).to redirect_to(assigns(:video))
      end
    end

    shared_examples "can't create by invalid resource" do
      it '権限のないリソースでは作成できない' do
        expect {
          post(videos_path, params: valid_params)
        }.not_to change(Video, :count)
      end
    end

    def valid_params
      {
        video: {
          title:      'サンプルビデオ2',
          video_file: uploaded_file,
        }
      }
    end

    before do
      upload_to_vimeo_mock
    end

    context '動画投稿者がログインしている場合' do
      before do
        sign_in user_staff
      end

      it_behaves_like "can_create"
      it_behaves_like "redirect_to_show"
    end

    context 'オーナーがログインしている場合' do
      before do
        sign_in user_owner
      end

      context 'パラメータが正常な場合' do
        it_behaves_like "can_create"
        it_behaves_like "redirect_to_show"
      end

      context 'パラメータが異常な場合' do
        it 'タイトルが空白だと新規作成されない' do
          expect {
            post videos_path,
              params: {
                video: {
                  title:      '',
                  video_file: uploaded_file
                }
              }
          }.not_to change(Video, :count)
        end

        it 'タイトルが重複していると新規作成されない' do
          upload_to_vimeo_mock
          video_sample

          expect {
            post videos_path,
              params: {
                video: {
                  title:      'サンプルビデオ',
                  video_file: uploaded_file
                }
              }
          }.not_to change(Video, :count)
        end

        it '動画が空白だと新規作成されない' do
          expect {
            post videos_path,
              params: {
                video: {
                  title: 'サンプルビデオ2'
                }
              }
          }.not_to change(Video, :count)
        end

        # TODO: it '動画の拡張子が不正だと新規作成されない' do; end

        it '登録失敗するとエラーを出す' do
          expect(
            post(videos_path,
              params: {
                video: {
                  title: ''
                }
              })
          ).to render_template :new
        end
      end
    end

    context 'システム管理者がログインしている場合' do
      before do
        sign_in system_admin
      end

      it_behaves_like "can't create by invalid resource" 
    end

    describe '視聴者がログインしている場合' do
      before do
        sign_in viewer
      end

      it_behaves_like "can't create by invalid resource" 
    end

    context '非ログイン状態の場合' do
      it_behaves_like "can't create by invalid resource" 
    end
  end

  describe 'GET #show' do
    before do
      upload_to_vimeo_mock
    end

    context '動画投稿者がログインしている場合' do
      before  do
        sign_in user_staff
        get video_path(video_sample)
      end

      it_behaves_like "access_success"
    end

    context 'オーナーがログインしている場合' do
      before do
        sign_in user_owner
        get video_path(video_sample)
      end

      it_behaves_like "access_success"
    end

    context '視聴者がログインしている場合' do
      before do
        organization_viewer
        sign_in viewer
        get video_path(video_sample)
      end

      it_behaves_like "access_success"
    end

    context '動画の視聴にログインが不要で、非ログイン状態の場合' do
      before do
        get video_path(video_sample)
      end

      it_behaves_like "access_success"
    end

    context '別組織のuserがログインしている場合' do
      before do
        sign_in another_user_owner
        get video_path(video_sample)
      end

      it_behaves_like "access_failure"
    end

    context '別組織の視聴者がログインしている場合' do
      before do
        sign_in another_viewer
        get video_path(video_sample)
      end

      it_behaves_like "access_failure"
    end

    # TODO: context '動画の視聴にログインが必要だが、非ログイン状態の場合' do end
  end

  describe 'PATCH #update' do

    before do
      upload_to_vimeo_mock
    end

    shared_examples "can_update" do
      # TODO: タイトル以外のカラムの更新についてはテストできていない
      it '動画情報がアップデートされる' do
        # patch video_path(video_sample, valid_params)の後、
        # video_sample.title → "サンプルビデオ"
        # video_sample.reload.title → "サンプルビデオ2"
        expect {
          patch video_path(video_sample, valid_params)
        }.to change { video_sample.reload.title }.from('サンプルビデオ').to('サンプルビデオ2')
      end
    end

    shared_examples "redirect_to_show" do
      it 'showにリダイレクトされる' do
        expect(
          patch video_path(video_sample, valid_params)
        ).to redirect_to video_path(video_sample)
      end
    end

    shared_examples "can't_update_by_invalid_resource" do
      it 'アップデートできない' do
        expect {
          patch video_path(video_sample, valid_params)
        .not_to change { video_sample.reload.title }.from('サンプルビデオ')
        }
      end
    end

    def valid_params
      {
        video: {
          title: 'サンプルビデオ2',
        }
      }
    end

    context 'オーナーがログインしている場合' do
      before do
        sign_in user_owner
      end

      context 'パラメータが正常な場合' do
        it_behaves_like 'can_update'
        it_behaves_like 'redirect_to_show'
      end

      context 'パラメータが異常な場合' do
        it 'タイトルが空白でアップデートされない' do
          expect {
            patch video_path(video_sample),
              params: {
                video: {
                  title: ''
                }, format: :js
              }
          }.not_to change { video_sample.reload.title }.from('サンプルビデオ')
        end
        
        it 'タイトルが重複してアップデートされない' do
          video_test

          expect {
            patch video_path(video_sample),
              params: {
                video: {
                  title: 'テストビデオ'
                }, format: :js
              }
          }.not_to change { video_sample.reload.title }.from('サンプルビデオ')
        end
        
        it '登録失敗するとモーダル上でエラーを出す' do
          expect(
            patch(video_path(video_sample),
              params: {
                video: {
                  title: ''
                }, format: :js
              })
          ).to render_template :edit
        end
      end
    end

    context '動画投稿者本人がログインしている場合' do
      before do
        # 不要なデータを作成しないよう、既存のデータを更新する形で対応
        # video_sampleの投稿者をオーナーから投稿者本人に変更しておく
        video_sample.update!(user_id: user_staff.id)
        sign_in user_staff
      end

      it_behaves_like 'can_update'
      it_behaves_like 'redirect_to_show'
    end

    describe 'システム管理者がログインしている場合' do
      before do
        sign_in system_admin
      end

      it_behaves_like 'can_update'
      it_behaves_like 'redirect_to_show'
    end

    context '本人以外の動画投稿者がログインしている場合' do
      before do
        sign_in user_staff
      end

      it_behaves_like "can't_update_by_invalid_resource" 
    end

    describe '別組織のオーナーがログインしている場合' do
      before do
        sign_in another_user_owner
      end

      it_behaves_like "can't_update_by_invalid_resource" 
    end

    describe '視聴者がログインしている場合' do
      before do
        sign_in viewer
      end

      it_behaves_like "can't_update_by_invalid_resource" 
    end

    describe '非ログイン状態の場合' do
      it_behaves_like "can't_update_by_invalid_resource" 
    end
  end

  describe 'DELETE #destroy' do
    shared_examples "can't_destroy" do
      it '削除できない' do
        expect { 
          delete video_path(video_sample)
        }.not_to change { Video.count }
      end
    end

    before do
      upload_to_vimeo_mock
      # ここで、video_sampleを呼び出してcreateしておかないと、以下のテストの時に、create(+1件)とdelete(-1件)となり、テストに落ちる(# expected `Video.count` to have changed by -1, but was changed by 0)
      # it '動画を削除する' do
      #   expect {
      #     delete video_path(video_sample)
      #   }.to change(Video, :count).by(-1)
      # end
      video_sample
      destroy_from_vimeo_mock
    end

    context 'システム管理者がログインしている場合' do
      before do
        sign_in system_admin
      end

      it '動画を削除する' do
        expect {
          delete video_path(video_sample)
        }.to change(Video, :count).by(-1)
      end

      it 'indexにリダイレクトされる' do
        expect(
          delete(video_path(video_sample), params: { id: video_sample.id })
        ).to redirect_to videos_path(organization_id: organization.id)
      end
    end

    context 'オーナーがログインしている場合' do
      before do
        sign_in user_owner
      end

      it_behaves_like "can't_destroy"
    end

    context '動画投稿者がログインしている場合' do
      before do
        sign_in user_staff
      end

      it_behaves_like "can't_destroy"
    end

    context '視聴者がログインしている場合' do
      before do
        sign_in viewer
      end
      
      it_behaves_like "can't_destroy"
    end

    context '非ログイン状態の場合' do
      it_behaves_like "can't_destroy"
    end
  end
end
