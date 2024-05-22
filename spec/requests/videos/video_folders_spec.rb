require 'rails_helper'

RSpec.describe 'VideoFolders', type: :request do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }

  let!(:organization) { create(:organization) }
  let!(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let!(:user_staff) { create(:user_staff, confirmed_at: Time.now) }

  let!(:another_organization) { create(:another_organization) }
  let!(:another_user_owner) { create(:another_user_owner, confirmed_at: Time.now) }

  let(:viewer) { create(:viewer, confirmed_at: Time.now) }

  let!(:folder_celeb) { create(:folder_celeb) }
  let!(:folder_tech) { create(:folder_tech) }
  
  let(:uploaded_file) { fixture_file_upload('aurora.mp4', 'video/mp4') } # ActionDispatch::Http::UploadedFileオブジェクト
  let(:video_sample) { create(:video_sample, video_file: uploaded_file) }
  
  let(:video_folder) { create(:video_folder) }

  before do
    upload_to_vimeo_mock
    video_sample
    video_folder
  end

  describe 'DELETE #destroy' do
    shared_examples "can_delete_and_redirect" do
      it 'フォルダ内の動画を削除する' do
        expect {
          delete video_video_folder_url(video_sample, video_folder, folder_id: folder_celeb.id, organization_id: organization.id)
        }.to change(VideoFolder, :count).by(-1)
      end

      it 'folders#showにリダイレクトされる' do
        expect(
          delete(video_video_folder_url(video_sample, video_folder, folder_id: folder_celeb.id, organization_id: organization.id))
        ).to redirect_to organization_folder_url(folder_celeb, organization_id: organization.id)
      end
    end

    shared_examples "can't_delete" do
      it '削除できない' do
        expect {
          delete video_video_folder_url(video_sample, video_folder, folder_id: folder_celeb.id, organization_id: organization.id)
        }.not_to change(VideoFolder, :count)
      end
    end

    describe 'システム管理者が現在のログインユーザー' do
      before do
        sign_in system_admin
      end

      it_behaves_like "can_delete_and_redirect"
    end

    describe 'オーナーが現在のログインユーザー' do
      before do
        sign_in user_owner
      end

      it_behaves_like "can_delete_and_redirect"
    end

    describe '本人以外の動画投稿者が現在のログインユーザ' do
      before do
        sign_in user_staff
      end

      it_behaves_like  "can't_delete" 
    end

    describe '別組織のオーナーが現在のログインユーザ' do
      before do
        sign_in another_user_owner
      end

      it_behaves_like  "can't_delete" 
    end

    describe '視聴者が現在のログインユーザ' do
      before do
        sign_in viewer
      end

      it_behaves_like  "can't_delete" 
    end

    describe '非ログイン' do
      it_behaves_like  "can't_delete" 
    end
  end
end
