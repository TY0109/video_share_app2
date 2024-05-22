require 'rails_helper'

RSpec.describe Video, type: :model do
  # let!は、宣言のタイミングでcreate, letは呼び出されたタイミングでcreate
  # organization, user_owner, user_staffは当ファイルで呼び出されないので、let!しておかないと、videoの作成時に関連付けができない
  let!(:organization) { create(:organization) }
  let!(:user_owner) { create(:user_owner, organization_id: organization.id) }
  let!(:user_staff) { create(:user_staff, organization_id: organization.id) }

  let(:uploaded_file) { fixture_file_upload('aurora.mp4', 'video/mp4') } # ActionDispatch::Http::UploadedFileオブジェクト
  let(:video_sample) { build(:video_sample, video_file: uploaded_file) }
  let(:video_test) { create(:video_test, video_file: uploaded_file) }
  
  describe "#バリデーションチェック" do
    context '正常な場合' do
      it '有効であること' do
        expect(video_sample).to be_valid
      end
    end

    context '異常な場合' do
      context 'タイトルにバリデーションエラーがある場合' do
        it '空白ではエラーになること' do
          video_sample.title = ''
          expect(video_sample).not_to be_valid
          expect(video_sample.errors.full_messages).to include('タイトルを入力してください')
        end

        it '重複するとエラーになること' do
          upload_to_vimeo_mock
          video_test
          video_sample.title = 'テストビデオ'
          expect(video_sample).not_to be_valid
          expect(video_sample.errors.full_messages).to include('タイトルはすでに存在します')
        end
      end

      context '組織IDにバリデーションエラーがある場合' do
        it '空白ではエラーになること' do
          video_sample.organization_id = ''
          expect(video_sample).not_to be_valid
          expect(video_sample.errors.full_messages).to include('組織を入力してください')
        end
      end

      context '投稿者IDにバリデーションエラーがある場合' do
        it '空白ではエラーになること' do
          video_sample.user_id = ''
          expect(video_sample).not_to be_valid
          expect(video_sample.errors.full_messages).to include('投稿者を入力してください')
        end
      end

      context 'video_fileにバリデーションエラーがある場合' do
        it 'nilではエラーになること' do
          video_sample.video_file = nil
          expect(video_sample).not_to be_valid
          expect(video_sample.errors.full_messages).to include('ビデオを入力してください')
        end

        it '拡張子が不正ではエラーになること' do
          video_sample.video_file.content_type = "image/png"
          expect(video_sample).not_to be_valid
          expect(video_sample.errors.full_messages).to include('ビデオの拡張子が不正です')
        end
      end
    end
  end

  describe "#upload_to_vimeo" do
    context 'vimeoに動画をアップできた場合' do
      it 'data_urlに動画のURLが格納され、保存に成功すること' do
        upload_to_vimeo_mock
        expect(video_sample.save).to eq true
        expect(video_sample.data_url).to eq("/videos/949110689")
      end

      # 上記テストをvcrで行う場合
      # 以下でvimeoへの動画投稿を実際に行いリクエストとレスポンスを記録
      # VCR.use_cassette("vimeo_upload") do
      #   vimeo_client = VimeoMe2::User.new(ENV['VIMEO_API_TOKEN'])
      #   vimeo_client.upload_video(uploaded_file)
      # end
      # → vcr_cassets/vimeo_upload.ymlが作成され記録される

      # it 'data_urlに動画のURLが格納され、保存に成功すること' do
      #   # vcr_cassets/vimeo_upload.ymlの結果を使い回すことで、実際に動画をアップしなくても、同じリクエストを送り同じレスポンスを得ることができる
      #   VCR.use_cassette("vimeo_upload") do
      #     expect(video_sample.save).to eq true
      #     expect(video_sample.data_url).to eq("/videos/949110689")
      #   end
      # end
    end

    context '認証エラーや容量超過でvimeoに動画をアップできなかった場合' do
      it 'data_urlに動画のURLが格納されず、保存に失敗すること' do
        # save前に呼び出されるupload_to_vimeoメソッドについて、
        # モック化して例外VimeoMe2::RequestFailedを発生させる
        vimeo_user_instance = instance_double(VimeoMe2::User)
        allow(VimeoMe2::User).to receive(:new).and_return(vimeo_user_instance)
        allow(vimeo_user_instance).to receive(:upload_video).and_raise(VimeoMe2::RequestFailed)
        expect(video_sample.save).to eq false
        expect(video_sample.data_url).to eq nil
      end
    end
  end
end
