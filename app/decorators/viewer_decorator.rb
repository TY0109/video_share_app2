# frozen_string_literal: true

module ViewerDecorator
  # 視聴率一覧ページで呼び出し
  def name_show
    current_user&.owner? ? name : (link_to name, viewer_path(self))
  end
  
  def complete_video_status(video_id)
    VideoStatus.find_by(video_id: video_id, viewer_id: id, watched_ratio: 100.0)
  end

  def incomplete_video_status(video_id)
    VideoStatus.find_by(video_id: video_id, viewer_id: id, watched_ratio: ...100.0)
  end

  def incomplete_video_status_watched_ratio(video_id)
    return incomplete_video_status(video_id)&.watched_ratio
    false
  end
end
