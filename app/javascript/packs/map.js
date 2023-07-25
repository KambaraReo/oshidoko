//初期マップの設定
let map;
let marker;

window.initMap = function() {
  geocoder = new google.maps.Geocoder()

  map = new google.maps.Map(document.getElementById('map'), {
    center: {lat: 35.65263243481742, lng: 139.73823818822285}, //東京
    zoom: 15,
  });
}

//検索後のマップ作成
let geocoder;
let aft;

window.codeAddress = function() {
  let inputAddress = document.getElementById('address').value;
  geocoder.geocode( { 'address': inputAddress}, function(results, status) {
    if (status == 'OK') {
      //マーカーが複数できないようにする
      if (aft == true){
        marker.setMap(null);
      }

      //新しくマーカーを作成する
      map.setCenter(results[0].geometry.location);
        marker = new google.maps.Marker({
        map: map,
        position: results[0].geometry.location,
        draggable: true	// ドラッグ可能にする
      });

      //二度目以降か判断
      aft = true

      //検索した時に緯度経度を入力する
      document.getElementById('add').value = results[0].formatted_address;
      document.getElementById('lat').value = results[0].geometry.location.lat();
      document.getElementById('lng').value = results[0].geometry.location.lng();

      // マーカーのドロップ（ドラッグ終了）時のイベント
      google.maps.event.addListener( marker, 'dragend', function(ev) {
        // 住所を取得
        geocoder.geocode({ 'location': ev.latLng }, function(results, status) {
          if (status === 'OK') {
            if (results[0]) {
              if (results[0].types.includes('plus_code')) {
                document.getElementById('add').value = "住所が存在しません";
              } else {
                document.getElementById('add').value = results[0].formatted_address;
              }
            } else {
              alert('住所が見つかりませんでした。');
            }
          } else {
            alert('該当する結果がありませんでした：' + status);
          }
        });
        // 緯度経度を取得
        document.getElementById('lat').value = ev.latLng.lat();
        document.getElementById('lng').value = ev.latLng.lng();
      });
    } else {
      alert('該当する結果がありませんでした：' + status);
    }
  });   
}
