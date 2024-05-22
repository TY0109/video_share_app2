require 'rails_helper'

RSpec.describe VideoFolder, type: :model do
  let!(:organization) { create(:organization) }
  let!(:user_owner) { create(:user_owner, organization_id: organization.id) }

  let(:uploaded_file) { fixture_file_upload('aurora.mp4', 'video/mp4') } # ActionDispatch::Http::UploadedFileオブジェクト
  let(:video_sample) { create(:video_sample, video_file: uploaded_file) }

  let!(:folder_celeb) { create(:folder_celeb) }

  let(:video_folder) { build(:video_folder) }

  before do
    upload_to_vimeo_mock
    video_sample
  end

  context '正常な場合' do
    it '正常値で保存可能' do
      expect(video_folder.valid?).to eq(true)
    end
  end

  context '異常な場合' do
    context 'ビデオIDにバリデーションエラーがある場合' do
      it '空白ではエラーになること' do
        video_folder.video_id = ''
        expect(video_folder.valid?).to eq(false)
        expect(video_folder.errors.full_messages).to include('Videoを入力してください')
      end
    end

    context 'フォルダーIDにバリデーションエラーがある場合' do
      it '空白ではエラーになること' do
        video_folder.folder_id = ''
        expect(video_folder.valid?).to eq(false)
        expect(video_folder.errors.full_messages).to include('Folderを入力してください')
      end
    end
  end
end
