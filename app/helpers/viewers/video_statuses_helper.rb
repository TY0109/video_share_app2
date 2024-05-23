module Viewers::VideoStatusesHelper
  # 視聴率を計算
  # ※ 最後の1秒を視聴していない場合でも、視聴率は100%と判定
  def calculate_watched_ratio(total_time_param, end_point_param)
    # 再生完了率を百分率で小数点以下1桁まで表示し、総時間から再生完了地点までの差が1秒以下の場合は100.0%と表す
    (total_time_param - end_point_param > 1) ? (end_point_param.to_f / total_time_param * 100).round(1) : 100.0
  end
end
