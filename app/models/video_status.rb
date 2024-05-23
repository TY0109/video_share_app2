class VideoStatus < ApplicationRecord
  belongs_to :video
  belongs_to :viewer

  def completely_watched?
    return watched_ratio == 100.0
  end

  def incorrect_latest_start_point?(start_point_param)
    # すでに保存されている再生完了時点 < 新たにとんでくる再生開始時点 の場合は保存を行わない ← とばし再生防止
    return end_point.to_i < start_point_param
  end

  def correct_latest_end_point?(end_point_param)
    # すでに保存されている再生完了時点 < 新たに送られてくる再生完了時点 の場合にのみ保存を行う。← 同じ部分を繰り返し視聴する場合には、保存しないようにするための対応
    return end_point.to_i < end_point_param
  end
end
