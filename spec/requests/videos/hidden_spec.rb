require 'rails_helper'

RSpec.describe 'VideoHidden', type: :request do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }

  let!(:organization) { create(:organization) }
  let!(:user_owner) { create(:user_owner, confirmed_at: Time.now) }
  let!(:user_staff) { create(:user_staff, confirmed_at: Time.now) }

  let!(:another_organization) { create(:another_organization) }
  let!(:another_user_owner) { create(:another_user_owner, confirmed_at: Time.now) }

  # orgにのみ属す
  let!(:viewer) { create(:viewer, confirmed_at: Time.now) }
  # orgとviewerの紐付け
  let!(:organization_viewer) { create(:organization_viewer) }

  let(:uploaded_file) { fixture_file_upload('aurora.mp4', 'video/mp4') } # ActionDispatch::Http::UploadedFileオブジェクト
  let(:video_sample) { create(:video_sample, video_file: uploaded_file) }

  before do
    upload_to_vimeo_mock
    destroy_from_vimeo_mock
  end
  
  # TODO: describe "#confirm" do; end

  describe '#withdraw' do
    shared_examples "can_logic_delete" do
      it '論理削除できる' do
        expect {
          patch videos_withdraw_path(video_sample)
        }.to change { video_sample.reload.is_valid }.from(true).to(false)
      end
    end

    shared_examples "can't_logic_delete" do
      it '論理削除できない' do
        expect {
          patch videos_withdraw_path(video_sample)
        }.not_to change { video_sample.reload.is_valid }.from(true)
      end
    end

    context 'システム管理者がログインしている場合' do
      before do
        sign_in system_admin
      end

      it_behaves_like "can_logic_delete"

      it '論理削除した後もvideos#showにアクセスできる' do
        expect {
          patch videos_withdraw_path(video_sample)
        }.to change { video_sample.reload.is_valid }.from(true).to(false)
        get video_path(video_sample)
        expect(response).to have_http_status(:success)
      end
    end

    context 'オーナーがログインしている場合' do
      before do
        sign_in user_owner
      end

      it_behaves_like "can_logic_delete"

      it '論理削除した後videos#showにアクセスできない' do
        expect {
          patch videos_withdraw_path(video_sample)
        }.to change { video_sample.reload.is_valid }.from(true).to(false)
        get video_path(video_sample)
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to root_url
      end
    end

    context '動画投稿者がログインしている場合' do
      before do
        sign_in user_staff
      end

      it_behaves_like "can't_logic_delete"
    end

    context '別組織のオーナーがログインしている場合' do
      before do
        sign_in another_user_owner
      end

      it_behaves_like "can't_logic_delete"
    end

    context '視聴者がログインしている場合' do
      before do
        sign_in viewer
      end

      it_behaves_like "can't_logic_delete"
    end

    context '非ログイン状態の場合' do
      it_behaves_like "can't_logic_delete"
    end
  end
end
