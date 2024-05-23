document.addEventListener("turbolinks:load", function() {
  let videoId = $('.video-id').attr('id');
  let viewerId = $('.viewer-id').attr('id');
  let videostatusId = $('.video-status-id').attr('id');
  
  // 動画操作のためのオブジェクト
  let media = new MediaElementPlayer('mv').media
  
  // 動画のメタデータの読み込みが完了すると発火
  media.addEventListener('loadedmetadata', function(){
    // 動画の総再生時間を取得
    document.getElementById('total').innerHTML = media.duration;
  });
  
  // 動画を再生すると発火
  media.addEventListener('timeupdate', function() {
    // 動画を再生した範囲の数を取得
    let replay_area_count = media.played.length
    // 動画の最新の再生開始・完了時点を取得
    // ※ 動画を色んな箇所で再生すると、動画を再生した範囲の数が複数になる。その中で最新の再生開始・完了時点を取得している
    document.getElementById('latest_start_point').innerHTML = media.played.start(replay_area_count-1);
    document.getElementById('latest_end_point').innerHTML = media.played.end(replay_area_count-1);
  })

  // 動画の視聴状況をサーバー側に送信
  function sendVideoStatus(videoId, videostatusId, data) {
    let ajaxOptions = {
      url: '/videos/' + videoId + '/video_statuses/' + (videostatusId ? videostatusId : ''),
      type: videostatusId ? 'PATCH' : 'POST',
      data: data,
      beforeSend: function(xhr){
        setCsrfToken(xhr)
      }
    };

    $.ajax(ajaxOptions);
  }

  // サーバー側に送信する動画の視聴状況を返す
  function data(start_point, end_point){
    return {
      video_status: {          
        // 動画の総時間
        total_time: media.duration,
        // 動画の最新の再生開始・完了時点
        start_point: start_point,
        end_point: end_point,
        video_id: videoId,
        viewer_id: viewerId
      }
    }
  }
  
  // CSRF対策
  function setCsrfToken(xhr) {
    xhr.setRequestHeader("X-CSRF-Token", $('meta[name="csrf-token"]').attr('content'));
  }
  
  // ポーズした時に、動画の視聴状況をサーバー側に送信
  media.addEventListener('pause', function(){
    sendVideoStatus(videoId, videostatusId, data(document.getElementById('latest_start_point').innerHTML, document.getElementById('latest_end_point').innerHTML));
  }); 
  
  // ページ遷移した時に、動画の視聴状況をサーバー側に送信
  $(window).on('beforeunload', function(){
    sendVideoStatus(videoId, videostatusId, data(document.getElementById('latest_start_point').innerHTML, document.getElementById('latest_end_point').innerHTML));
  });
});
