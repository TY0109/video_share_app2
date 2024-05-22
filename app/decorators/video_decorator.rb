class VideoDecorator < Draper::Decorator
  delegate_all

  def ensure_owner?(current_user)
    return current_user.owner?
  end

  def selected_before_range
    return ['限定公開', 1] if range?
    false
  end

  def selected_before_comment_public
    return ['非公開', 1] if comment_public?
    false
  end

  def selected_before_login_set
    return ['ログイン必要', 1] if login_set?
    false
  end

  def selected_before_popup_before_video
    return ['動画視聴開始時ポップアップ非表示', 1] if popup_before_video?
    false
  end

  def selected_before_popup_after_video
    return ['動画視聴終了時ポップアップ非表示', 1] if popup_after_video?
    false
  end
end
 